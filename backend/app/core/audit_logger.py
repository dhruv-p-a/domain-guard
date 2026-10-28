import logging
from datetime import datetime
from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit_log import AuditLog

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("domainguard.audit")

async def log_audit_event(
    db: AsyncSession,
    user_id: Optional[int],
    action: str,
    target_type: str,
    target_id: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None,
    ip_address: Optional[str] = None,
):
    """
    Logs administrative and security-sensitive actions without logging sensitive secrets.
    """
    # Sanitize details to remove keys/passwords/tokens
    safe_details = {}
    if details:
        for k, v in details.items():
            if any(secret_kw in k.lower() for secret_kw in ["token", "secret", "password", "key", "auth"]):
                safe_details[k] = "***REDACTED***"
            else:
                safe_details[k] = str(v)

    logger.info(f"AUDIT | User: {user_id} | Action: {action} | Target: {target_type}/{target_id} | IP: {ip_address}")

    audit_entry = AuditLog(
        user_id=user_id,
        action=action,
        target_type=target_type,
        target_id=target_id,
        details=safe_details,
        ip_address=ip_address,
        created_at=datetime.utcnow()
    )
    db.add(audit_entry)
    await db.commit()
