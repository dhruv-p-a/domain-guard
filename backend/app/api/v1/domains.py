from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.domain import Domain
from app.schemas.domain import DomainAddRequest, DomainOut, DomainVerifyResponse
from app.services.domain_verification_service import DomainVerificationService

router = APIRouter()

@router.get("", response_model=List[DomainOut])
async def list_domains(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(select(Domain).where(Domain.user_id == current_user.id))
    domains = result.scalars().all()
    return domains

@router.post("", response_model=DomainOut)
async def add_domain(
    payload: DomainAddRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Adds a domain for monitoring and generates ownership verification token.
    Enforces SSRF protection on target domain.
    """
    domain = await DomainVerificationService.add_domain(
        db, current_user, payload.domain_name, payload.verification_method
    )
    return domain

@router.post("/{domain_id}/verify", response_model=DomainVerifyResponse)
async def verify_domain(
    domain_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Domain).where(Domain.id == domain_id, Domain.user_id == current_user.id)
    )
    domain = result.scalars().first()
    if not domain:
        raise HTTPException(status_code=404, detail="Domain not found")

    is_ok, msg = await DomainVerificationService.verify_domain_ownership(db, domain)
    return DomainVerifyResponse(
        domain_name=domain.domain_name,
        is_verified=is_ok,
        message=msg,
        record_name=f"_domainguard-challenge.{domain.domain_name}",
        record_type="TXT",
        record_value=domain.verification_token
    )

@router.delete("/{domain_id}")
async def delete_domain(
    domain_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Domain).where(Domain.id == domain_id, Domain.user_id == current_user.id)
    )
    domain = result.scalars().first()
    if not domain:
        raise HTTPException(status_code=404, detail="Domain not found")

    await db.delete(domain)
    await db.commit()
    return {"message": f"Domain {domain.domain_name} deleted successfully"}
