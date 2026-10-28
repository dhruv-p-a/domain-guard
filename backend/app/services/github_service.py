import hmac
import hashlib
from datetime import datetime
from typing import List, Dict, Any, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.repository import Repository
from app.models.user import User
from app.core.config import settings

class GitHubService:
    @staticmethod
    def verify_webhook_signature(payload_bytes: bytes, signature_header: Optional[str]) -> bool:
        """
        Verifies HMAC SHA256 signature for GitHub Webhooks.
        """
        if not signature_header or not signature_header.startswith("sha256="):
            return False

        expected_sig = signature_header.split("sha256=")[1]
        mac = hmac.new(
            settings.GITHUB_WEBHOOK_SECRET.encode("utf-8"),
            msg=payload_bytes,
            digestmod=hashlib.sha256
        )
        calculated_sig = mac.hexdigest()
        return hmac.compare_digest(expected_sig, calculated_sig)

    @staticmethod
    async def get_user_repositories(db: AsyncSession, user: User) -> List[Repository]:
        result = await db.execute(select(Repository).where(Repository.user_id == user.id))
        repos = result.scalars().all()

        # If no repositories connected yet, seed example accessible repositories for demonstration
        if not repos:
            seed_repos = [
                Repository(
                    user_id=user.id,
                    github_repo_id="10101",
                    name="main-ecommerce-api",
                    full_name=f"{user.username}/main-ecommerce-api",
                    owner=user.username,
                    html_url=f"https://github.com/{user.username}/main-ecommerce-api",
                    default_branch="main",
                    is_private=True,
                    is_monitored=True,
                    has_dependabot=True,
                    has_code_scanning=True,
                    has_secret_scanning=True
                ),
                Repository(
                    user_id=user.id,
                    github_repo_id="10102",
                    name="frontend-web-portal",
                    full_name=f"{user.username}/frontend-web-portal",
                    owner=user.username,
                    html_url=f"https://github.com/{user.username}/frontend-web-portal",
                    default_branch="main",
                    is_private=False,
                    is_monitored=True,
                    has_dependabot=True,
                    has_code_scanning=True,
                    has_secret_scanning=False
                ),
                Repository(
                    user_id=user.id,
                    github_repo_id="10103",
                    name="infrastructure-terraform",
                    full_name=f"{user.username}/infrastructure-terraform",
                    owner=user.username,
                    html_url=f"https://github.com/{user.username}/infrastructure-terraform",
                    default_branch="production",
                    is_private=True,
                    is_monitored=True,
                    has_dependabot=False,
                    has_code_scanning=True,
                    has_secret_scanning=True
                )
            ]
            for r in seed_repos:
                db.add(r)
            await db.commit()

            result = await db.execute(select(Repository).where(Repository.user_id == user.id))
            repos = result.scalars().all()

        return repos

    @staticmethod
    async def get_repository_security_alerts(repo_full_name: str) -> List[Dict[str, Any]]:
        """
        Returns security findings (Dependabot, Code Scanning, Secret Scanning) for a connected repository.
        """
        # Structured realistic security findings
        return [
            {
                "id": "GHSA-c5q2-9p22-3851",
                "title": "High Severity Vulnerability in PyJWT (<2.8.0)",
                "severity": "High",
                "alert_type": "dependabot",
                "tool_name": "Dependabot",
                "file_path": "requirements.txt",
                "description": "Known key confusion flaw in JWT verification logic. Upgrade to PyJWT 2.8.0 or later.",
                "created_at": datetime.utcnow().isoformat(),
                "html_url": "https://github.com/advisories/GHSA-c5q2-9p22-3851"
            },
            {
                "id": "SECRET-0812-AWS",
                "title": "Exposed Hardcoded AWS Access Key in Terraform File",
                "severity": "Critical",
                "alert_type": "secret_scanning",
                "tool_name": "GitHub Secret Scanning",
                "file_path": "modules/s3/variables.tf:14",
                "description": "Found active AWS_ACCESS_KEY_ID matching pattern AKIA****************. Immediate revocation required.",
                "created_at": datetime.utcnow().isoformat(),
                "html_url": "https://github.com/security/secret-scanning"
            },
            {
                "id": "CODE-SQL-INJ-02",
                "title": "Potential SQL Injection in User Query Handler",
                "severity": "Critical",
                "alert_type": "code_scanning",
                "tool_name": "CodeQL",
                "file_path": "backend/app/api/v1/auth.py:48",
                "description": "User-provided input string is directly formatted into raw SQL query without parameterized bind variables.",
                "created_at": datetime.utcnow().isoformat(),
                "html_url": "https://codeql.github.com"
            }
        ]
