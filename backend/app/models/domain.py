from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, JSON
from app.core.database import Base

class Domain(Base):
    __tablename__ = "domains"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    domain_name = Column(String, index=True, nullable=False)
    verification_token = Column(String, nullable=False)
    is_verified = Column(Boolean, default=False)
    verification_method = Column(String, default="DNS_TXT")  # DNS_TXT or HTTP_FILE
    monitoring_status = Column(String, default="Active")  # Active, Paused, Error

    ssl_status = Column(String, default="Unknown")  # Valid, ExpiringSoon, Expired, Error
    ssl_expiry_date = Column(DateTime, nullable=True)
    ssl_issuer = Column(String, nullable=True)

    dns_status = Column(String, default="Configured")
    security_headers_score = Column(String, default="B")  # A+, A, B, C, D, F

    subdomains_found = Column(JSON, default=list)
    last_checked_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
