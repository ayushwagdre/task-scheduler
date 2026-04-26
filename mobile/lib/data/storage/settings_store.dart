import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsStore {
  SettingsStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _kRemindersEnabled = 'reminders_enabled';

  Future<bool> getRemindersEnabled() async {
    final v = await _storage.read(key: _kRemindersEnabled);
    if (v == null) return true; // default ON for MVP
    return v == 'true';
  }

  Future<void> setRemindersEnabled(bool v) async {
    await _storage.write(key: _kRemindersEnabled, value: v ? 'true' : 'false');
  }
}

