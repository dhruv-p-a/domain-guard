import asyncio
from app.workers.celery_app import celery_app
from app.services.passive_monitoring_service import PassiveMonitoringService

@celery_app.task(name="tasks.run_periodic_domain_scan")
def run_periodic_domain_scan(domain_name: str):
    """
    Background job executing passive SSL, DNS, Header security check on schedule.
    """
    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(PassiveMonitoringService.run_full_domain_scan(domain_name))
    return {
        "domain": domain_name,
        "health": result.overall_health,
        "findings": result.findings_count
    }
