from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.repository import Repository
from app.models.domain import Domain
from app.models.security_event import SecurityEvent
from app.models.notification import Notification
from app.models.integration import Integration
from app.schemas.user import UserOut, NotificationSettingsUpdate

router = APIRouter()

@router.put("/notifications")
async def update_notification_settings(
    payload: NotificationSettingsUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    current_settings = dict(current_user.notification_settings or {})
    if payload.email_alerts is not None:
        current_settings["email_alerts"] = payload.email_alerts
    if payload.critical_only is not None:
        current_settings["critical_only"] = payload.critical_only
    if payload.weekly_summary is not None:
        current_settings["weekly_summary"] = payload.weekly_summary
    if payload.min_severity is not None:
        current_settings["min_severity"] = payload.min_severity

    current_user.notification_settings = current_settings
    await db.commit()
    await db.refresh(current_user)
    return {"message": "Notification preferences updated", "settings": current_user.notification_settings}

@router.delete("/account")
async def delete_user_account_and_data(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Complete account deletion and data purge as required by Section 3.J.
    """
    user_id = current_user.id

    # Delete connected resources
    await db.execute(Domain.__table__.delete().where(Domain.user_id == user_id))
    await db.execute(Repository.__table__.delete().where(Repository.user_id == user_id))
    await db.execute(SecurityEvent.__table__.delete().where(SecurityEvent.user_id == user_id))
    await db.execute(Notification.__table__.delete().where(Notification.user_id == user_id))
    await db.execute(Integration.__table__.delete().where(Integration.user_id == user_id))
    await db.delete(current_user)
    await db.commit()

    return {"message": "User account and all associated security data permanently deleted."}
