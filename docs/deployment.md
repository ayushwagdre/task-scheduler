## Deployment (MVP)

### Backend (Go + Postgres)
Recommended simple options:\n+- Render / Railway / Fly.io\n+- Managed Postgres add-on\n+
Minimum required environment variables:\n+- `DATABASE_URL`\n+- `JWT_SECRET`\n+- `PORT`\n+- `ACCESS_TOKEN_TTL_MINUTES`\n+- `SCHEDULER_ENABLED`\n+- `SCHEDULER_TICK_SECONDS`\n+
#### Migrations
Run:\n+\n+```bash
cd backend
go run ./cmd/migrate up
```\n+
### Mobile (Flutter Android)
- Build with:\n+\n+```bash
cd mobile
flutter build appbundle
```\n+
### Production safety notes
- Always use HTTPS.\n+- Store secrets in the platform’s secret manager.\n+- Rotate `JWT_SECRET` if leaked.\n+
