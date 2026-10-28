from typing import List, Dict, Any, Optional
from pydantic import BaseModel

class SSLCheckResult(BaseModel):
    is_valid: bool
    status: str  # Valid, ExpiringSoon, Expired, Untrusted, Unreachable
    issuer: str
    subject: str
    valid_from: str
    valid_until: str
    days_remaining: int
    cipher_suite: Optional[str] = None

class HeaderCheckResult(BaseModel):
    score: str  # A+, A, B, C, D, F
    headers_found: Dict[str, str]
    headers_missing: List[str]
    recommendations: List[str]

class DNSCheckResult(BaseModel):
    a_records: List[str]
    aaaa_records: List[str]
    mx_records: List[str]
    txt_records: List[str]
    ns_records: List[str]
    has_spf: bool
    has_dmarc: bool

class ExposedConfigResult(BaseModel):
    paths_checked: int
    exposed_files: List[Dict[str, str]]
    is_safe: bool

class SubdomainsResult(BaseModel):
    count: int
    subdomains: List[str]

class DomainSecurityCheckSummary(BaseModel):
    domain_name: str
    overall_health: str  # Secure, Warning, AtRisk
    ssl: SSLCheckResult
    headers: HeaderCheckResult
    dns: DNSCheckResult
    exposed: ExposedConfigResult
    subdomains: SubdomainsResult
    findings_count: int
