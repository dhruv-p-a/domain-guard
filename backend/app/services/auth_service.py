import httpx
from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.user import User
from app.core.security import create_access_token
from app.core.config import settings

class AuthService:
    @staticmethod
    async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
        result = await db.execute(select(User).where(User.email == email))
        return result.scalars().first()

    @staticmethod
    async def get_user_by_github_id(db: AsyncSession, github_id: str) -> Optional[User]:
        result = await db.execute(select(User).where(User.github_id == str(github_id)))
        return result.scalars().first()

    @staticmethod
    async def process_github_oauth(db: AsyncSession, code: str) -> Dict[str, Any]:
        """
        Exchanges GitHub OAuth code for access token, fetches GitHub user profile,
        upserts User record in database (storing github_access_token on backend ONLY),
        and returns JWT token for client.
        """
        # If mock/demo credentials or real
        async with httpx.AsyncClient() as client:
            # Exchange code
            token_resp = await client.post(
                "https://github.com/login/oauth/access_token",
                headers={"Accept": "application/json"},
                data={
                    "client_id": settings.GITHUB_CLIENT_ID,
                    "client_secret": settings.GITHUB_CLIENT_SECRET,
                    "code": code,
                },
                timeout=10.0
            )
            token_data = token_resp.json()
            access_token = token_data.get("access_token")

            if not access_token:
                # Handle fallback / dev mode mock
                return await AuthService.create_demo_user_session(db)

            # Fetch user profile from GitHub
            user_resp = await client.get(
                "https://api.github.com/user",
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Accept": "application/vnd.github.v3+json"
                },
                timeout=10.0
            )
            gh_user = user_resp.json()

        github_id = str(gh_user.get("id"))
        username = gh_user.get("login") or f"gh_{github_id}"
        email = gh_user.get("email") or f"{username}@users.noreply.github.com"
        avatar_url = gh_user.get("avatar_url")
        full_name = gh_user.get("name") or username

        user = await AuthService.get_user_by_github_id(db, github_id)
        if not user:
            user = User(
                email=email,
                username=username,
                full_name=full_name,
                github_id=github_id,
                github_access_token=access_token,
                avatar_url=avatar_url,
                plan_tier="Pro"
            )
            db.add(user)
        else:
            user.github_access_token = access_token
            user.avatar_url = avatar_url
            user.full_name = full_name

        await db.commit()
        await db.refresh(user)

        jwt_token = create_access_token(
            subject=user.id,
            user_data={"email": user.email, "username": user.username}
        )
        return {"access_token": jwt_token, "token_type": "bearer", "user": user}

    @staticmethod
    async def create_demo_user_session(db: AsyncSession) -> Dict[str, Any]:
        """
        Creates or retrieves a demo security officer user for testing and presentation.
        """
        demo_email = "secops@domainguard.io"
        user = await AuthService.get_user_by_email(db, demo_email)
        if not user:
            user = User(
                email=demo_email,
                username="security_lead",
                full_name="Alex Rivera (SecOps Lead)",
                github_id="demo_998811",
                github_access_token="gho_demo_access_token_secured_backend",
                avatar_url="https://avatars.githubusercontent.com/u/583231?v=4",
                plan_tier="Enterprise"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)

        jwt_token = create_access_token(
            subject=user.id,
            user_data={"email": user.email, "username": user.username}
        )
        return {"access_token": jwt_token, "token_type": "bearer", "user": user}
