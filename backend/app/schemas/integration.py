from datetime import datetime
from typing import Dict, Any
from pydantic import BaseModel, ConfigDict

class IntegrationCreate(BaseModel):
    provider: str  # cloudflare, hosting_logs, server_auth
    name: str
    config: Dict[str, Any] = {}

class IntegrationOut(BaseModel):
    id: int
    user_id: int
    provider: str
    name: str
    status: str
    config: Dict[str, Any]
    last_synced_at: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class SampleLogIngestRequest(BaseModel):
    provider: str
    log_type: str  # waf_event, auth_failure, rate_limit
    payload: Dict[str, Any]
