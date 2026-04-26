## Android exact alarms + notifications (MVP)

This doc describes the Android wiring required for exact alarms and reminder notifications in a Play-policy-safe way.

### Permissions (Android 13+ and Android 12+)
- `android.permission.POST_NOTIFICATIONS`\n+- `android.permission.SCHEDULE_EXACT_ALARM`\n+
Best practice:\n+- Request `POST_NOTIFICATIONS` in-context (when enabling reminders).\n+- Exact alarm access is a special app access; show an in-app toggle and deep link to system settings.\n+
### Notification UX
- Use a dedicated notification channel (high importance).\n+- Avoid full-screen intents unless you genuinely implement an alarm clock style experience.\n+- Provide easy opt-out.\n+
### Platform channel approach (Flutter)
Implement a `MethodChannel` wrapper in `lib/platform/android_alarm/`:\n+- `scheduleExactAlarm(taskId, triggerAtEpochMillis, title)`\n+- `cancelAlarm(taskId)`\n+
On Android:\n+- `BroadcastReceiver` receives the alarm intent and posts a notification.\n+- Tapping notification opens the app to complete the task.\n+
### Play compliance notes
- Only use exact alarms for user-visible time-sensitive reminders.\n+- Describe why you need exact alarms in your store listing and in-app explanation.\n+
