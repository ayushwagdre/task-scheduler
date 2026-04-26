import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../storage/settings_store.dart';
import '../storage/token_store.dart';

String _simpleId() {
  // Lightweight unique-enough id for MVP analytics; avoid adding deps.
  return '${DateTime.now().microsecondsSinceEpoch}-${Object().hashCode}';
}

class AppAnalytics {
  AppAnalytics(this._api, this._settings);

  final ApiClient _api;
  final SettingsStore _settings;

  Future<String> ensureInstallId() async {
    final existing = await _settings.getInstallId();
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _simpleId();
    await _settings.setInstallId(id);
    return id;
  }

  Future<void> trackInstallOnce() async {
    final sent = await _settings.getInstallEventSent();
    if (sent) return;
    final installId = await ensureInstallId();
    await _api.postJson('/events', {'installId': installId, 'eventType': 'install', 'metadata': {}});
    await _settings.setInstallEventSent(true);
  }

  Future<void> trackOnboardingCompleted() async {
    final installId = await ensureInstallId();
    await _api.postJson('/events', {'installId': installId, 'eventType': 'onboarding_completed', 'metadata': {}});
  }
}

AppAnalytics buildAnalytics() {
  const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  final storage = const FlutterSecureStorage();
  final api = ApiClient(baseUrl: baseUrl, tokenStore: TokenStore(storage));
  final settings = SettingsStore(storage);
  return AppAnalytics(api, settings);
}

