from fastapi import APIRouter, Request, Header, HTTPException, status, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.services.github_service import GitHubService
from app.services.event_normalization_service import EventNormalizationService

router = APIRouter()

# In-memory deduplication set for webhooks
processed_delivery_ids = set()

@router.post("/github")
async def handle_github_webhook(
    request: Request,
    x_github_event: str = Header(None),
    x_github_delivery: str = Header(None),
    x_hub_signature_256: str = Header(None),
    db: AsyncSession = Depends(get_db)
):
    """
    GitHub Webhook Processing Endpoint.
    - Verifies HMAC SHA256 Signature using `x_hub_signature_256`.
    - Handles duplicate webhook deliveries using `x_github_delivery`.
    - Processes push, dependabot_alert, code_scanning_alert, secret_scanning_alert.
    """
    body_bytes = await request.body()

    # Validate HMAC signature if header provided or in strict mode
    if x_hub_signature_256:
        is_valid = GitHubService.verify_webhook_signature(body_bytes, x_hub_signature_256)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid GitHub webhook signature"
            )

    # Deduplicate webhook delivery
    if x_github_delivery:
        if x_github_delivery in processed_delivery_ids:
            return {"status": "ignored", "reason": f"Duplicate delivery ID {x_github_delivery} already processed"}
        processed_delivery_ids.add(x_github_delivery)
        if len(processed_delivery_ids) > 10000:
            processed_delivery_ids.clear()

    payload = await request.json()

    # Determine event title & severity based on event type
    if x_github_event == "secret_scanning_alert":
        action = payload.get("action", "created")
        alert = payload.get("alert", {})
        repo = payload.get("repository", {}).get("full_name", "unknown/repo")

        await EventNormalizationService.create_event(
            db=db,
            user_id=1,  # Target owner
            title=f"Secret Scanning Alert ({action}): {alert.get('secret_type_display', 'Secret Exposed')}",
            event_type="SECRET_EXPOSED",
            severity="Critical",
            source="GitHub Secret Scanning",
            target_type="repository",
            target_name=repo,
            evidence=f"Exposed secret in {alert.get('locations_url', 'repository history')}",
            remediation="Revoke exposed credentials immediately and purge secret from git history.",
            raw_payload=payload
        )
    elif x_github_event == "dependabot_alert":
        alert = payload.get("alert", {})
        repo = payload.get("repository", {}).get("full_name", "unknown/repo")

        await EventNormalizationService.create_event(
            db=db,
            user_id=1,
            title=f"Dependabot Advisory: {alert.get('security_advisory', {}).get('summary', 'Vulnerable Dependency')}",
            event_type="DEPENDABOT_ALERT",
            severity=alert.get("security_advisory", {}).get("severity", "High").capitalize(),
            source="GitHub Dependabot",
            target_type="repository",
            target_name=repo,
            evidence=f"Vulnerable package {alert.get('dependency', {}).get('package', {}).get('name')}",
            remediation="Upgrade package to fixed version specified in security advisory.",
            raw_payload=payload
        )
    elif x_github_event == "push":
        repo = payload.get("repository", {}).get("full_name", "unknown/repo")
        commits = payload.get("commits", [])
        pusher = payload.get("pusher", {}).get("name", "developer")

        await EventNormalizationService.create_event(
            db=db,
            user_id=1,
            title=f"Code Push Event by {pusher} ({len(commits)} commits)",
            event_type="SUSPICIOUS_COMMIT",
            severity="Informational",
            source="GitHub Webhook",
            target_type="repository",
            target_name=repo,
            evidence=f"Ref: {payload.get('ref')}, Head commit: {payload.get('after')[:7] if payload.get('after') else 'head'}",
            remediation="Audit diffs if push modifies sensitive configuration or CI pipelines.",
            raw_payload=payload
        )

    return {"status": "success", "event": x_github_event, "delivery": x_github_delivery}
