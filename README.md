# DomainGuard — Website Security Monitoring Platform

DomainGuard is a production-oriented cybersecurity monitoring platform that connects authorized GitHub repositories and hosting/security services to continuously monitor security events, vulnerabilities, suspicious commits, exposed secrets, and domain health.

---

## Architecture Overview

- **Frontend (`/frontend`)**: Built with Flutter (Dart), Material 3 design, supporting Responsive Web, Android, iOS, and Desktop. Uses reactive state management with `Provider`, HTTP networking with JWT authentication, and interactive `fl_chart` time-series visualization.
- **Backend (`/backend`)**: Built with Python FastAPI, SQLAlchemy (Async), Pydantic v2 schemas, JWT authentication, and SSRF security protection. Supports SQLite out of the box for fast development and PostgreSQL for production environments.
- **Background Tasks & Workers**: Celery worker with Redis broker for background scanning and scheduled audits.
- **Security Features**: Domain ownership enforcement via DNS TXT records, HMAC SHA256 webhook signature validation, SSRF protection against private IP targets/localhost/cloud metadata endpoints, rate limiting, and audit logging.

---

## Directory Structure

```text
domain_guard/
  frontend/
    lib/
      main.dart
      app.dart
      core/
        config/          # API endpoints configuration
        networking/      # HTTP ApiClient with JWT token handler
        theme/           # Material 3 dark cybersecurity theme & colors
        widgets/         # Reusable UI widgets (StatCard, SeverityBadge, StatusChip, etc.)
      features/
        landing/         # Marketing landing page & pricing
        authentication/ # GitHub OAuth login & demo mode
        dashboard/       # Main dashboard, summary cards & trend charts
        github/          # GitHub App & repository security alerts
        domains/         # Domain management & DNS TXT verification
        monitoring/      # Passive SSL, DNS, Security Header audits
        events/          # Unified security event timeline & detail modal
        integrations/    # Cloudflare WAF, hosting & server auth log ingestion
        notifications/   # In-app alerts & feed
        settings/        # User profile & account deletion controls
  backend/
    app/
      main.py
      api/               # FastAPI routers (v1 endpoints)
      core/              # Configuration, security JWT, SSRF protection, rate limiting
      models/            # SQLAlchemy DB models
      schemas/           # Pydantic v2 request & response schemas
      services/          # Domain verification, passive scanner, GitHub OAuth
      workers/           # Celery workers & scheduled tasks
    tests/               # Pytest suite with async unit tests
    requirements.txt     # Backend dependencies
  docker-compose.yml
  .env.example
  README.md
```

---

## Getting Started

### 1. Prerequisites

- Python 3.10+
- Flutter SDK (3.13+)
- Git
- Docker & Docker Compose (Optional for containerized run)

### 2. Backend Setup & Local Running

1. Navigate to the backend directory:
   ```bash
   cd domain_guard/backend
   ```
2. Create virtual environment & install requirements:
   ```bash
   python -m venv venv
   # On Windows PowerShell:
   .\venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Run test suite:
   ```bash
   pytest
   ```
4. Start the FastAPI development server:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```
5. Access interactive API documentation:
   - OpenAPI Docs: `http://127.0.0.1:8000/api/v1/docs`

---

### 3. Frontend Setup & Local Running

1. Navigate to the frontend directory:
   ```bash
   cd domain_guard/frontend
   ```
2. Install pub dependencies:
   ```bash
   flutter pub get
   ```
3. Run tests & analysis:
   ```bash
   flutter test
   flutter analyze
   ```
4. Run Flutter application on Web or Desktop:
   ```bash
   flutter run -d chrome
   # or
   flutter run -d windows
   ```

---

### 4. Running with Docker Compose

To start PostgreSQL, Redis, Celery Worker, and FastAPI Backend simultaneously:

```bash
cd domain_guard
docker-compose up --build
```

---

## GitHub OAuth & App Setup

1. Register a GitHub OAuth App or GitHub App in your GitHub Account Settings -> Developer Settings.
2. Set the Authorization Callback URL to: `http://localhost:8000/api/v1/auth/github/callback`.
3. Copy `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, and `GITHUB_WEBHOOK_SECRET` into `.env`.
4. DomainGuard also provides a **SecOps Demo Mode** for immediate evaluation without requiring live OAuth keys.
