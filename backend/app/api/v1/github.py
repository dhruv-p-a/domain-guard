from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.repository import Repository
from app.schemas.repository import RepositoryOut, SecurityAlertOut
from app.services.github_service import GitHubService

router = APIRouter()

@router.get("/repositories", response_model=List[RepositoryOut])
async def list_repositories(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Returns accessible GitHub repositories with least-privilege permission status.
    """
    return await GitHubService.get_user_repositories(db, current_user)

@router.post("/repositories/{repo_id}/toggle")
async def toggle_repository_monitoring(
    repo_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Repository).where(Repository.id == repo_id, Repository.user_id == current_user.id)
    )
    repo = result.scalars().first()
    if not repo:
        raise HTTPException(status_code=404, detail="Repository not found")

    repo.is_monitored = not repo.is_monitored
    await db.commit()
    await db.refresh(repo)
    return {"message": f"Monitoring {'enabled' if repo.is_monitored else 'disabled'} for {repo.full_name}", "repository": repo}

@router.get("/repositories/{repo_id}/alerts", response_model=List[SecurityAlertOut])
async def get_repo_alerts(
    repo_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Repository).where(Repository.id == repo_id, Repository.user_id == current_user.id)
    )
    repo = result.scalars().first()
    if not repo:
        raise HTTPException(status_code=404, detail="Repository not found")

    alerts = await GitHubService.get_repository_security_alerts(repo.full_name)
    return alerts
