from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, EmailStr, ConfigDict

class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    plan_tier: str = "Pro"

class UserCreate(UserBase):
    github_id: Optional[str] = None
    github_access_token: Optional[str] = None

class NotificationSettingsUpdate(BaseModel):
    email_alerts: Optional[bool] = None
    critical_only: Optional[bool] = None
    weekly_summary: Optional[bool] = None
    min_severity: Optional[str] = None

class UserOut(UserBase):
    id: int
    is_active: bool
    is_admin: bool
    notification_settings: Dict[str, Any]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
