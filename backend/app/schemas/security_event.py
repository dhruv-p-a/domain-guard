from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, ConfigDict

class SecurityEventCreate(BaseModel):
    title: str
    event_type: str
    severity: str  # Critical, High, Medium, Low, Informational
    source: str
    target_type: str
    target_name: str
    evidence: Optional[str] = None
    remediation: Optional[str] = None
    raw_payload: Optional[Dict[str, Any]] = None

class SecurityEventUpdate(BaseModel):
    status: str  # Open, Acknowledged, Resolved

class SecurityEventOut(BaseModel):
    id: int
    user_id: int
    title: str
    event_type: str
    severity: str
    source: str
    target_type: str
    target_name: str
    evidence: Optional[str] = None
    remediation: Optional[str] = None
    status: str
    created_at: datetime
    resolved_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class EventTimelineFilter(BaseModel):
    severity: Optional[str] = None
    source: Optional[str] = None
    status: Optional[str] = None
    search: Optional[str] = None
    page: int = 1
    page_size: int = 20
