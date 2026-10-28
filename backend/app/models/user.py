from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, JSON
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=True)
    github_id = Column(String, unique=True, index=True, nullable=True)
    github_access_token = Column(String, nullable=True)  # Stored securely on backend only
    avatar_url = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    plan_tier = Column(String, default="Pro")  # Free, Pro, Enterprise
    notification_settings = Column(JSON, default=lambda: {
        "email_alerts": True,
        "critical_only": False,
        "weekly_summary": True,
        "min_severity": "Low"
    })
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
