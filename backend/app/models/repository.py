from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, JSON
from app.core.database import Base

class Repository(Base):
    __tablename__ = "repositories"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    github_repo_id = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    owner = Column(String, nullable=False)
    html_url = Column(String, nullable=False)
    default_branch = Column(String, default="main")
    is_private = Column(Boolean, default=False)
    is_monitored = Column(Boolean, default=True)

    # Feature flags supported
    has_dependabot = Column(Boolean, default=True)
    has_code_scanning = Column(Boolean, default=True)
    has_secret_scanning = Column(Boolean, default=True)

    last_synced_at = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
