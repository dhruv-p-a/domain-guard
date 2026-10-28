from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class RepositoryBase(BaseModel):
    github_repo_id: str
    name: str
    full_name: str
    owner: str
    html_url: str
    default_branch: str = "main"
    is_private: bool = False
    is_monitored: bool = True

class RepositoryCreate(RepositoryBase):
    pass

class RepositoryUpdate(BaseModel):
    is_monitored: Optional[bool] = None

class RepositoryOut(RepositoryBase):
    id: int
    user_id: int
    has_dependabot: bool
    has_code_scanning: bool
    has_secret_scanning: bool
    last_synced_at: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class SecurityAlertOut(BaseModel):
    id: str
    title: str
    severity: str
    alert_type: str  # dependabot, code_scanning, secret_scanning
    tool_name: Optional[str] = None
    file_path: Optional[str] = None
    description: str
    created_at: datetime
    html_url: Optional[str] = None
