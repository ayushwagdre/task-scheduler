## Google Play Data safety (MVP notes)

Use this as a checklist to keep your Play Console declarations aligned with the app.

### Data collected (MVP)
- **Email**: for account creation and login.\n+- **User-generated content**: tasks (title, schedule), completion events.\n+- **App activity**: streak counters derived from completions.\n+
Optional / future:\n+- **Device or other IDs**: push token for notifications (FCM) if enabled.

### Data usage purposes
- App functionality (accounts, syncing, reminders, streaks).\n+- No advertising.\n+- No data brokerage.

### Data sharing
- No sharing for advertising/marketing.\n+- Hosting provider is a service processor.\n+
### Security practices
- Encrypted in transit (HTTPS) in production.\n+- Password hashing.\n+
### Account deletion
- In-app deletion endpoint exists (`DELETE /me`) and clears server-side user data.

### Permissions rationale (Android)
- `POST_NOTIFICATIONS`: to show task reminders.\n+- `SCHEDULE_EXACT_ALARM`: to deliver reminders at the exact time configured by the user.\n+
Best practice:\n+- Ask in-context.\n+- Provide in-app setting to disable exact alarms and revert to best-effort scheduling.

