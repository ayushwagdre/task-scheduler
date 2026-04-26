import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/storage/token_store.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._tokenStore);

  final TokenStore _tokenStore;

  bool _initialized = false;
  bool _loggedIn = false;

  bool get initialized => _initialized;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    final token = await _tokenStore.getAccessToken();
    _loggedIn = token != null && token.isNotEmpty;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLoggedIn(bool v) async {
    _loggedIn = v;
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStore.clear();
    _loggedIn = false;
    notifyListeners();
  }
}

final authState = AuthState(TokenStore(const FlutterSecureStorage()));

