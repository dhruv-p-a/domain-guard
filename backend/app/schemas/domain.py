from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict

class DomainAddRequest(BaseModel):
    domain_name: str = Field(..., json_schema_extra={"example": "example.com"})
    verification_method: str = Field("DNS_TXT", json_schema_extra={"example": "DNS_TXT"})

class DomainOut(BaseModel):
    id: int
    user_id: int
    domain_name: str
    verification_token: str
    is_verified: bool
    verification_method: str
    monitoring_status: str
    ssl_status: str
    ssl_expiry_date: Optional[datetime] = None
    ssl_issuer: Optional[str] = None
    dns_status: str
    security_headers_score: str
    subdomains_found: List[str] = []
    last_checked_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class DomainVerifyResponse(BaseModel):
    domain_name: str
    is_verified: bool
    message: str
    record_name: str
    record_type: str
    record_value: str
