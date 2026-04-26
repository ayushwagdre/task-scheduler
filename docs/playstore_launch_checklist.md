## Google Play launch checklist (MVP)

### Store listing (avoid policy issues)
- App description matches functionality (task reminders + streaks).
- No deceptive “pay” claims in MVP (no penalties implemented).
- Screenshots show real UI.

### Permissions (declare + justify)
- `POST_NOTIFICATIONS`: reminders.\n+- `SCHEDULE_EXACT_ALARM`: time-sensitive user-set reminders.\n+
In-app:\n+- Ask notification permission in context.\n+- Provide a toggle and explanation for exact alarms.\n+
### Privacy policy + Data safety
- Host privacy policy URL (public).\n+- Link to policy in-app and in store listing.\n+- Data safety form matches actual collection.\n+
### Account deletion (required for many account-based apps)
- In-app “Delete account” flows.\n+- Backend endpoint available (`DELETE /me`).\n+- Confirm deletion and clear local secure storage.\n+
### Security + compliance
- Use HTTPS in production.\n+- JWT secret is rotated and stored securely.\n+- Passwords hashed (bcrypt).\n+
### Release readiness
- Test on Android 12–15.\n+- Validate alarm behavior under Doze/battery optimization.\n+- Ensure notifications are not spammy and can be disabled.\n+
