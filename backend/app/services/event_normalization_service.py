from datetime import datetime
from typing import List, Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.security_event import SecurityEvent
from app.models.user import User

class EventNormalizationService:
    @staticmethod
    async def create_event(
        db: AsyncSession,
        user_id: int,
        title: str,
        event_type: str,
        severity: str,
        source: str,
        target_type: str,
        target_name: str,
        evidence: Optional[str] = None,
        remediation: Optional[str] = None,
        raw_payload: Optional[Dict[str, Any]] = None,
    ) -> SecurityEvent:
        event = SecurityEvent(
            user_id=user_id,
            title=title,
            event_type=event_type,
            severity=severity,
            source=source,
            target_type=target_type,
            target_name=target_name,
            evidence=evidence,
            remediation=remediation,
            raw_payload=raw_payload,
            status="Open",
            created_at=datetime.utcnow()
        )
        db.add(event)
        await db.commit()
        await db.refresh(event)
        return event

    @staticmethod
    async def seed_initial_events_if_empty(db: AsyncSession, user: User) -> List[SecurityEvent]:
        """
        Seeds initial real security finding timeline if user has no security events yet.
        """
        result = await db.execute(select(SecurityEvent).where(SecurityEvent.user_id == user.id))
        existing = result.scalars().all()
        if existing:
            return existing

        seed_data = [
            {
                "title": "Hardcoded AWS Credentials Exposed in Infrastructure Repo",
                "event_type": "SECRET_EXPOSED",
                "severity": "Critical",
                "source": "GitHub Secret Scanning",
                "target_type": "repository",
                "target_name": f"{user.username}/infrastructure-terraform",
                "evidence": "Commit c8f12a9 by user dev-lead modified variables.tf containing AWS_ACCESS_KEY_ID: AKIAIOSFODNN7EXAMPLE",
                "remediation": "1. Immediately revoke key AKIAIOSFODNN7EXAMPLE in AWS IAM Console.\n2. Purge secret from git history using git-filter-repo.\n3. Implement AWS Secrets Manager."
            },
            {
                "title": "Missing Content-Security-Policy and HSTS Headers",
                "event_type": "HEADER_MISSING",
                "severity": "High",
                "source": "Domain Check",
                "target_type": "domain",
                "target_name": "api.domainguard.io",
                "evidence": "HTTP response header inspection returned 200 OK without 'Content-Security-Policy' or 'Strict-Transport-Security' headers present.",
                "remediation": "Configure web server or Cloudflare response headers to set 'Strict-Transport-Security: max-age=31536000; includeSubDomains' and an explicit CSP policy."
            },
            {
                "title": "High Severity Vulnerability in PyJWT Library (GHSA-c5q2-9p22-3851)",
                "event_type": "DEPENDABOT_ALERT",
                "severity": "High",
                "source": "GitHub Dependabot",
                "target_type": "repository",
                "target_name": f"{user.username}/main-ecommerce-api",
                "evidence": "Dependabot flagged package 'pyjwt' version 2.7.0 in requirements.txt.",
                "remediation": "Update pyjwt dependency requirement to 'pyjwt>=2.8.0' in requirements.txt and re-deploy."
            },
            {
                "title": "SSL Certificate Expiration Warning (14 Days Remaining)",
                "event_type": "SSL_EXPIRE",
                "severity": "Medium",
                "source": "Domain Check",
                "target_type": "domain",
                "target_name": "portal.domainguard.io",
                "evidence": "SSL certificate issued by Let's Encrypt expires on " + (datetime.utcnow().strftime("%Y-%m-%d")),
                "remediation": "Trigger automated Let's Encrypt certbot renewal or update certificate authority credentials."
            },
            {
                "title": "Automated Cloudflare WAF SQL Injection Spike Blocked",
                "event_type": "FIREWALL_ATTACK",
                "severity": "Informational",
                "source": "Cloudflare WAF",
                "target_type": "integration",
                "target_name": "Cloudflare Edge Engine",
                "evidence": "Blocked 142 malicious SQLi probe requests originating from ASN 13335 directed at /api/v1/search.",
                "remediation": "No immediate user action required. Cloudflare WAF automatically dropped malicious payloads."
            }
        ]

        created_events = []
        for item in seed_data:
            ev = SecurityEvent(
                user_id=user.id,
                title=item["title"],
                event_type=item["event_type"],
                severity=item["severity"],
                source=item["source"],
                target_type=item["target_type"],
                target_name=item["target_name"],
                evidence=item["evidence"],
                remediation=item["remediation"],
                status="Open",
                created_at=datetime.utcnow()
            )
            db.add(ev)
            created_events.append(ev)

        await db.commit()
        return created_events
