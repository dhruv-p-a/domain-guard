from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.security_event import SecurityEvent
from app.schemas.security_event import SecurityEventOut, SecurityEventUpdate
from app.services.event_normalization_service import EventNormalizationService

router = APIRouter()

@router.get("", response_model=List[SecurityEventOut])
async def list_security_events(
    severity: Optional[str] = Query(None),
    source: Optional[str] = Query(None),
    status_filter: Optional[str] = Query(None, alias="status"),
    search: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Unified Security Event Timeline with full filtering, sorting, searching, and status tracking.
    """
    # Seed events if user doesn't have any yet
    events = await EventNormalizationService.seed_initial_events_if_empty(db, current_user)

    stmt = select(SecurityEvent).where(SecurityEvent.user_id == current_user.id)
    if severity and severity != "All":
        stmt = stmt.where(SecurityEvent.severity == severity)
    if source and source != "All":
        stmt = stmt.where(SecurityEvent.source == source)
    if status_filter and status_filter != "All":
        stmt = stmt.where(SecurityEvent.status == status_filter)

    stmt = stmt.order_by(SecurityEvent.created_at.desc())
    result = await db.execute(stmt)
    event_list = result.scalars().all()

    if search:
        s = search.lower()
        event_list = [
            e for e in event_list
            if s in e.title.lower() or s in e.target_name.lower() or (e.evidence and s in e.evidence.lower())
        ]

    return event_list

@router.patch("/{event_id}", response_model=SecurityEventOut)
async def update_event_status(
    event_id: int,
    payload: SecurityEventUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(SecurityEvent).where(SecurityEvent.id == event_id, SecurityEvent.user_id == current_user.id)
    )
    event = result.scalars().first()
    if not event:
        raise HTTPException(status_code=404, detail="Security event not found")

    event.status = payload.status
    await db.commit()
    await db.refresh(event)
    return event
