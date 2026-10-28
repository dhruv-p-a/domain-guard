from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON, Text
from app.core.database import Base

class SecurityEvent(Base):
    __tablename__ = "security_events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    title = Column(String, nullable=False)
    event_type = Column(String, nullable=False)  # SSL_EXPIRE, HEADER_MISSING, DEPENDABOT_ALERT, SECRET_EXPOSED, SUSPICIOUS_COMMIT, EXPOSED_FILE, FIREWALL_ATTACK
    severity = Column(String, nullable=False)   # Critical, High, Medium, Low, Informational

    source = Column(String, nullable=False)      # Domain Check, GitHub App, Cloudflare WAF, Server Log
    target_type = Column(String, nullable=False) # domain, repository, integration
    target_name = Column(String, nullable=False) # e.g. example.com or org/repo

    evidence = Column(Text, nullable=True)
    remediation = Column(Text, nullable=True)
    status = Column(String, default="Open")      # Open, Acknowledged, Resolved

    raw_payload = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    resolved_at = Column(DateTime, nullable=True)
