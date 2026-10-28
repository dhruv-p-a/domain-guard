from fastapi import APIRouter, Depends, Query
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.monitoring import DomainSecurityCheckSummary
from app.services.passive_monitoring_service import PassiveMonitoringService
from app.core.ssrf import validate_target_domain_or_url

router = APIRouter()

@router.get("/scan", response_model=DomainSecurityCheckSummary)
async def scan_domain_security(
    domain: str = Query(..., examples=["api.domainguard.io"]),
    current_user: User = Depends(get_current_user)
):
    """
    Executes safe, non-destructive passive security checks on a verified target domain:
    - SSL Certificate Expiration & Cipher strength
    - Security Headers Posture (HSTS, CSP, X-Frame-Options, etc.)
    - DNS Records (A, AAAA, MX, TXT, SPF, DMARC)
    - Public Exposed Configs & Sensitive files indicators
    - Subdomains
    """
    clean_target = validate_target_domain_or_url(domain)
    summary = await PassiveMonitoringService.run_full_domain_scan(clean_target)
    return summary
