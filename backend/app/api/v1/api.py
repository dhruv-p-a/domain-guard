from fastapi import APIRouter
from app.api.v1 import auth, dashboard, github, domains, monitoring, events, integrations, notifications, settings, webhooks

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])
api_router.include_router(github.router, prefix="/github", tags=["GitHub Integration"])
api_router.include_router(domains.router, prefix="/domains", tags=["Domain Management"])
api_router.include_router(monitoring.router, prefix="/monitoring", tags=["Security Monitoring"])
api_router.include_router(events.router, prefix="/events", tags=["Security Events"])
api_router.include_router(integrations.router, prefix="/integrations", tags=["Hosting & Firewalls"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["Alerts & Notifications"])
api_router.include_router(settings.router, prefix="/settings", tags=["User Settings"])
api_router.include_router(webhooks.router, prefix="/webhooks", tags=["Webhooks"])
