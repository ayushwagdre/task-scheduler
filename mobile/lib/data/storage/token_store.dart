import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';

  Future<void> setAccessToken(String token) => _storage.write(key: _kAccessToken, value: token);
  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<void> clear() => _storage.deleteAll();
}

