import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'afcon_api.dart';

abstract interface class FanTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureFanTokenStore implements FanTokenStore {
  const SecureFanTokenStore();

  static const _storage = FlutterSecureStorage();
  static const _key = 'afcon_fan_session_token';

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class FanAccount {
  const FanAccount({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  factory FanAccount.fromJson(Map<String, dynamic> json) => FanAccount(
    id: '${json['id'] ?? ''}',
    email: '${json['email'] ?? ''}',
    displayName:
        '${json['displayName'] ?? json['display_name'] ?? 'AFCON Fan'}',
  );
}

class FanSession {
  FanSession({AfconApi? api, FanTokenStore? tokenStore})
    : _api = api ?? AfconApi(),
      _tokenStore = tokenStore ?? const SecureFanTokenStore();

  static final FanSession instance = FanSession();

  final AfconApi _api;
  final FanTokenStore _tokenStore;
  String? _token;
  FanAccount? _account;

  String? get token => _token;
  FanAccount? get account => _account;
  bool get isSignedIn => _token != null && _account != null;

  Future<FanAccount?> restore() async {
    final savedToken = await _tokenStore.read();
    if (savedToken == null || savedToken.isEmpty) return null;

    try {
      final response = await _api.currentFan(savedToken);
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('The account response is invalid.');
      }
      _token = savedToken;
      _account = FanAccount.fromJson(data);
      return _account;
    } on AfconApiException catch (error) {
      if (error.statusCode == 401) {
        await _tokenStore.clear();
        _token = null;
        _account = null;
      }
      rethrow;
    }
  }

  Future<FanAccount> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.registerFan(
      name: name,
      email: email,
      password: password,
    );
    return _acceptAuthResponse(response);
  }

  Future<FanAccount> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _api.loginFan(email: email, password: password);
    return _acceptAuthResponse(response);
  }

  Future<FanAccount> updateDisplayName(String displayName) async {
    final currentToken = _token;
    if (currentToken == null) {
      throw StateError('Sign in before changing your display name.');
    }
    final response = await _api.updateFanName(
      token: currentToken,
      displayName: displayName,
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('The account response is invalid.');
    }
    _account = FanAccount.fromJson(data);
    return _account!;
  }

  Future<void> signOut() async {
    await _tokenStore.clear();
    _token = null;
    _account = null;
  }

  Future<FanAccount> _acceptAuthResponse(Map<String, dynamic> response) async {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('The sign-in response is invalid.');
    }
    final token = data['token']?.toString();
    final user = data['user'];
    if (token == null || token.isEmpty || user is! Map<String, dynamic>) {
      throw const FormatException('The sign-in response is incomplete.');
    }
    await _tokenStore.write(token);
    _token = token;
    _account = FanAccount.fromJson(user);
    return _account!;
  }
}
