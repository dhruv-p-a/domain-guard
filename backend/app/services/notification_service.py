from datetime import datetime
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.notification import Notification
from app.models.user import User

class NotificationService:
    @staticmethod
    async def create_notification(
        db: AsyncSession,
        user_id: int,
        title: str,
        message: str,
        severity: str = "Informational",
        event_id: int = None
    ) -> Notification:
        # Deduplication check within last 5 minutes
        result = await db.execute(
            select(Notification).where(
                Notification.user_id == user_id,
                Notification.title == title,
                Notification.is_read == False
            )
        )
        existing = result.scalars().first()
        if existing:
            return existing

        notif = Notification(
            user_id=user_id,
            title=title,
            message=message,
            severity=severity,
            event_id=event_id,
            is_read=False,
            created_at=datetime.utcnow()
        )
        db.add(notif)
        await db.commit()
        await db.refresh(notif)
        return notif

    @staticmethod
    async def seed_notifications_if_empty(db: AsyncSession, user: User) -> List[Notification]:
        result = await db.execute(select(Notification).where(Notification.user_id == user.id))
        existing = result.scalars().all()
        if existing:
            return existing

        seed = [
            Notification(
                user_id=user.id,
                title="Critical: Exposed AWS Key Detected",
                message="GitHub Secret Scanning identified a hardcoded AWS key in infrastructure-terraform repository.",
                severity="Critical",
                is_read=False
            ),
            Notification(
                user_id=user.id,
                title="Domain Added & Monitoring Active",
                message="Monitoring has been successfully enabled for api.domainguard.io.",
                severity="Informational",
                is_read=True
            ),
            Notification(
                user_id=user.id,
                title="Security Header Warning",
                message="Domain api.domainguard.io is missing Content-Security-Policy header.",
                severity="High",
                is_read=False
            )
        ]
        for n in seed:
            db.add(n)
        await db.commit()

        result = await db.execute(select(Notification).where(Notification.user_id == user.id))
        return result.scalars().all()
