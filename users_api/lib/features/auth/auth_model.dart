import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? initialToken}) : _token = initialToken;

  final SecureStore _store;

  String? _token;
  bool _signingIn = false;

  bool get signedIn => _token != null;
  String? get token => _token;
  bool get signingIn => _signingIn;

  Future<void> login(String email, String password) async {
    if (_signingIn) return;
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }

    _signingIn = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final tok = 'tok_${email.trim().hashCode}';
      await _store.saveToken(tok);
      _token = tok;
    } finally {
      _signingIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
