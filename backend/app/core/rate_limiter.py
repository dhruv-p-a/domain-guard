import time
from collections import defaultdict
from fastapi import HTTPException, Request, status

class RateLimiter:
    def __init__(self, requests_per_minute: int = 60):
        self.requests_per_minute = requests_per_minute
        self.requests = defaultdict(list)

    async def check_rate_limit(self, request: Request, identifier: str = None):
        client_ip = identifier or (request.client.host if request.client else "127.0.0.1")
        now = time.time()
        minute_ago = now - 60

        # Filter timestamps older than 60s
        self.requests[client_ip] = [t for t in self.requests[client_ip] if t > minute_ago]

        if len(self.requests[client_ip]) >= self.requests_per_minute:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded. Please try again later."
            )

        self.requests[client_ip].append(now)

rate_limiter = RateLimiter(requests_per_minute=100)
scan_rate_limiter = RateLimiter(requests_per_minute=20)
