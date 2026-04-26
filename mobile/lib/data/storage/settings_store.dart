import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsStore {
  SettingsStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _kRemindersEnabled = 'reminders_enabled';
  static const _kInstallId = 'install_id';
  static const _kInstallEventSent = 'install_event_sent';
  static const _kHasSeenOnboarding = 'has_seen_onboarding';

  Future<bool> getRemindersEnabled() async {
    final v = await _storage.read(key: _kRemindersEnabled);
    if (v == null) return true; // default ON for MVP
    return v == 'true';
  }

  Future<void> setRemindersEnabled(bool v) async {
    await _storage.write(key: _kRemindersEnabled, value: v ? 'true' : 'false');
  }

  Future<String?> getInstallId() => _storage.read(key: _kInstallId);
  Future<void> setInstallId(String id) => _storage.write(key: _kInstallId, value: id);

  Future<bool> getInstallEventSent() async {
    final v = await _storage.read(key: _kInstallEventSent);
    return v == 'true';
  }

  Future<void> setInstallEventSent(bool v) async {
    await _storage.write(key: _kInstallEventSent, value: v ? 'true' : 'false');
  }

  Future<bool> getHasSeenOnboarding() async {
    final v = await _storage.read(key: _kHasSeenOnboarding);
    return v == 'true';
  }

  Future<void> setHasSeenOnboarding(bool v) async {
    await _storage.write(key: _kHasSeenOnboarding, value: v ? 'true' : 'false');
  }
}

