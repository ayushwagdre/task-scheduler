## DoOrPay (MVP)

Production-ready MVP for a tasks + alarms + streaks app with a Go backend and a Flutter Android client.

### Project layout
- `backend/`: Go API + scheduler + Postgres migrations
- `mobile/`: Flutter app (Android-focused MVP)
- `docs/`: Play Store compliance docs (privacy policy template, data safety notes)

### Backend: run locally
Prereqs: Docker, Go 1.22+

1) Start Postgres

```bash
docker compose up -d
```

2) Copy env and edit as needed

```bash
cp backend/.env.example backend/.env
```

3) Run migrations

```bash
cd backend
go run ./cmd/migrate up
```

4) Start API

```bash
go run ./cmd/api
```

API default: `http://localhost:8080`

### Backend: example requests

Signup:

```bash
curl -sS -X POST http://localhost:8080/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"StrongPassw0rd!"}'
```

Login:

```bash
TOKEN="$(curl -sS -X POST http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"StrongPassw0rd!"}' | jq -r .accessToken)"
echo "$TOKEN"
```

Create a task:

```bash
curl -sS -X POST http://localhost:8080/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"title":"Drink water","timezone":"Asia/Kolkata","schedule":{"type":"daily","hour":9,"minute":0}}'
```

List tasks:

```bash
curl -sS http://localhost:8080/tasks -H "Authorization: Bearer $TOKEN"
```

Complete a task:

```bash
curl -sS -X POST http://localhost:8080/tasks/TASK_ID/complete \
  -H "Authorization: Bearer $TOKEN"
```

Get streak:

```bash
curl -sS http://localhost:8080/streaks -H "Authorization: Bearer $TOKEN"
```

Delete account (Play compliance):

```bash
curl -sS -X DELETE http://localhost:8080/me -H "Authorization: Bearer $TOKEN"
```

### Mobile (Flutter)
The Flutter app is a scaffold focused on correct architecture + Android alarm/notification handling.

See `mobile/README.md`.

### Google Play compliance docs
- Privacy policy template: `docs/privacy_policy_template.md`
- Data safety notes: `docs/play_data_safety_notes.md`



/Users/ayushwgadre/Library/Android/sdk/platform-tools/adb devices -l
flutter pub get
flutter run
flutter run -d chrome

flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
