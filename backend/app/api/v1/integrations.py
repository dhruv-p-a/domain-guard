from datetime import datetime
from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.integration import Integration
from app.schemas.integration import IntegrationCreate, IntegrationOut, SampleLogIngestRequest
from app.services.event_normalization_service import EventNormalizationService

router = APIRouter()

@router.get("", response_model=List[IntegrationOut])
async def list_integrations(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(Integration).where(Integration.user_id == current_user.id))
    integrations = result.scalars().all()
    if not integrations:
        # Seed default integrations
        i1 = Integration(
            user_id=current_user.id,
            provider="cloudflare",
            name="Cloudflare Edge WAF & Security Logs",
            status="Connected",
            config={"zone_id": "cf_zone_88291039", "logpush_enabled": True},
            last_synced_at=datetime.utcnow()
        )
        i2 = Integration(
            user_id=current_user.id,
            provider="server_auth",
            name="Linux SSH / Auth System Logs",
            status="Connected",
            config={"log_agent": "syslog-ng-agent-v2", "monitored_nodes": 3},
            last_synced_at=datetime.utcnow()
        )
        i3 = Integration(
            user_id=current_user.id,
            provider="hosting_logs",
            name="AWS CloudWatch / Hosting Access Logs",
            status="Connected",
            config={"log_group": "/aws/httpd/access_log"},
            last_synced_at=datetime.utcnow()
        )
        db.add_all([i1, i2, i3])
        await db.commit()
        result = await db.execute(select(Integration).where(Integration.user_id == current_user.id))
        integrations = result.scalars().all()

    return integrations

@router.post("", response_model=IntegrationOut)
async def create_integration(
    payload: IntegrationCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Redact sensitive parameters in stored config
    safe_config = {}
    for k, v in payload.config.items():
        if any(secret in k.lower() for secret in ["key", "secret", "token", "password"]):
            safe_config[k] = "***REDACTED***"
        else:
            safe_config[k] = v

    integration = Integration(
        user_id=current_user.id,
        provider=payload.provider,
        name=payload.name,
        status="Connected",
        config=safe_config,
        last_synced_at=datetime.utcnow()
    )
    db.add(integration)
    await db.commit()
    await db.refresh(integration)
    return integration

@router.post("/ingest-sample-log")
async def ingest_sample_log(
    payload: SampleLogIngestRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Simulates log payload ingestion from external security sources (Cloudflare WAF / Server SSH / Hosting logs).
    Normalizes log into a SecurityEvent entry.
    """
    event = await EventNormalizationService.create_event(
        db=db,
        user_id=current_user.id,
        title=f"Security Alert from {payload.provider.title()} ({payload.log_type})",
        event_type="FIREWALL_ATTACK" if payload.provider == "cloudflare" else "SUSPICIOUS_COMMIT",
        severity="High" if "fail" in payload.log_type or "attack" in payload.log_type else "Medium",
        source=f"{payload.provider.title()} Integration",
        target_type="integration",
        target_name=payload.provider,
        evidence=f"Payload details: {str(payload.payload)}",
        remediation="Review IP blocking rules and rate-limiting configurations.",
        raw_payload=payload.payload
    )
    return {"message": "Log ingested and normalized into security event timeline", "event": event}

@router.get("/info")
async def integration_architecture_info():
    """
    Explains scope restrictions & boundary separation between GitHub repo access and live traffic logs.
    """
    return {
        "title": "Architecture & Boundary Notice",
        "explanation": "GitHub repository access alone grants visibility into source code, commits, and repository security alerts (Dependabot, Secret Scanning, CodeQL). "
                       "It does NOT grant access to live web server processes, SSH login attempts, or incoming network traffic. "
                       "To monitor live firewall events, Cloudflare WAF, or server authentication logs, connect these integrations separately via secure API webhooks or log agents.",
        "supported_sources": [
            {"provider": "cloudflare", "name": "Cloudflare Logpush / WAF Events API"},
            {"provider": "server_auth", "name": "Linux auth.log / SSH Login Agent"},
            {"provider": "hosting_logs", "name": "AWS CloudWatch / Nginx Access Logs"}
        ]
    }
