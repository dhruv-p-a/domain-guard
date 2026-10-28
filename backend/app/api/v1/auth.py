from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user
from app.schemas.user import UserOut, Token
from app.models.user import User
from app.services.auth_service import AuthService
from app.core.config import settings

router = APIRouter()

@router.get("/github/login")
async def github_login_url():
    """
    Returns GitHub OAuth authorize URL for frontend redirect.
    """
    redirect_uri = f"https://github.com/login/oauth/authorize?client_id={settings.GITHUB_CLIENT_ID}&scope=repo,read:user,user:email"
    return {"url": redirect_uri}

@router.get("/github/callback", response_model=Token)
async def github_callback(code: str = Query(...), db: AsyncSession = Depends(get_db)):
    """
    Handles secure OAuth callback from GitHub.
    Stores GitHub token securely on backend ONLY.
    """
    token_response = await AuthService.process_github_oauth(db, code)
    return token_response

@router.post("/demo-login", response_model=Token)
async def demo_login(db: AsyncSession = Depends(get_db)):
    """
    Provides immediate authenticated access for SecOps evaluation / demo.
    """
    token_response = await AuthService.create_demo_user_session(db)
    return token_response

@router.get("/me", response_model=UserOut)
async def read_current_user_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    return {"message": "Successfully logged out. Session terminated."}
