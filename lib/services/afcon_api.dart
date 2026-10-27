import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Flutter client for the AFCON Fan TypeScript API.
/// Override the development URL with --dart-define=AFCON_API_URL=...
class AfconApi {
  AfconApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _configuredBaseUrl = String.fromEnvironment(
    'AFCON_API_URL',
    defaultValue: '',
  );

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080/api/v1'
        : 'http://localhost:8080/api/v1';
  }

  final http.Client _client;
  final String _baseUrl;

  Future<List<Map<String, dynamic>>> competitions({int limit = 50}) =>
      _getCollection('competitions', {'limit': '$limit'});

  Future<List<Map<String, dynamic>>> matches({
    String? date,
    String? status,
    String? competitionId,
    String? teamId,
  }) => _getCollection('matches', {
    if (date != null) 'date': date,
    if (status != null) 'status': status,
    if (competitionId != null) 'competitionId': competitionId,
    if (teamId != null) 'teamId': teamId,
  });

  Future<List<Map<String, dynamic>>> teams({
    String? competitionId,
    String? region,
  }) => _getCollection('teams', {
    if (competitionId != null) 'competitionId': competitionId,
    if (region != null) 'region': region,
  });

  Future<List<Map<String, dynamic>>> players({
    String? teamId,
    String? competitionId,
  }) => _getCollection('players', {
    if (teamId != null) 'teamId': teamId,
    if (competitionId != null) 'competitionId': competitionId,
  });

  Future<List<Map<String, dynamic>>> standings({
    required String competitionId,
    String? group,
  }) => _getCollection('standings', {
    'competitionId': competitionId,
    if (group != null) 'group': group,
  });

  Future<List<Map<String, dynamic>>> venues({String? city}) =>
      _getCollection('venues', {if (city != null) 'city': city});

  Future<List<Map<String, dynamic>>> news({String? category, String? region}) =>
      _getCollection('news', {
        if (category != null) 'category': category,
        if (region != null) 'region': region,
      });

  Future<List<Map<String, dynamic>>> events({String? city, String? region}) =>
      _getCollection('events', {
        if (city != null) 'city': city,
        if (region != null) 'region': region,
      });

  Future<List<Map<String, dynamic>>> media({String? type, String? teamId}) =>
      _getCollection('media', {
        if (type != null) 'type': type,
        if (teamId != null) 'teamId': teamId,
      });

  Future<List<Map<String, dynamic>>> matchEvents({required String matchId}) =>
      _getCollection('match-events', {'matchId': matchId});

  Future<List<Map<String, dynamic>>> lineups({
    required String matchId,
    String? teamId,
  }) => _getCollection('lineups', {
    'matchId': matchId,
    if (teamId != null) 'teamId': teamId,
  });

  Future<List<Map<String, dynamic>>> matchStatistics({
    required String matchId,
  }) => _getCollection('match-statistics', {'matchId': matchId});

  Future<Map<String, dynamic>> qualifiers() async {
    final uri = Uri.parse(
      '${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/qualifiers',
    );
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    final data = _decode(response)['data'];
    if (data is! Map<String, dynamic>) {
      throw const AfconApiException(
        200,
        'invalid_response',
        'The AFCON service returned an unexpected response.',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> askAssistant({
    required String question,
    String language = 'auto',
  }) => _post('assistant/ask', {'question': question, 'language': language});

  Future<Map<String, dynamic>> registerFan({
    required String name,
    required String email,
    required String password,
  }) => _post('auth/register', {
    'name': name,
    'email': email,
    'password': password,
  });

  Future<Map<String, dynamic>> loginFan({
    required String email,
    required String password,
  }) => _post('auth/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> currentFan(String token) =>
      _getObject('auth/me', token);

  Future<Map<String, dynamic>> updateFanName({
    required String token,
    required String displayName,
  }) => _patch('auth/me', {'displayName': displayName}, token: token);

  Future<List<Map<String, dynamic>>> communityPosts({String? token}) =>
      _getCollection('community/posts', const {}, token: token);

  Future<Map<String, dynamic>> uploadCommunityMedia({
    required String token,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) => _post('community/uploads', {
    'filename': filename,
    'mimeType': mimeType,
    'data': base64Encode(bytes),
  }, token: token);

  Future<Map<String, dynamic>> createCommunityPost({
    required String token,
    required String content,
    required List<Map<String, String>> media,
  }) => _post('community/posts', {
    'content': content,
    'media': media,
  }, token: token);

  Future<void> deleteCommunityPost({
    required String token,
    required String postId,
  }) => _delete('community/posts/$postId', token: token);

  Future<void> setCommunityPostLiked({
    required String token,
    required String postId,
    required bool liked,
  }) => liked
      ? _put('community/posts/$postId/like', const {}, token: token)
      : _delete('community/posts/$postId/like', token: token);

  Future<List<Map<String, dynamic>>> communityComments({
    required String postId,
    String? token,
  }) => _getCollection(
    'community/posts/$postId/comments',
    const {},
    token: token,
  );

  Future<Map<String, dynamic>> addCommunityComment({
    required String token,
    required String postId,
    required String content,
  }) => _post('community/posts/$postId/comments', {
    'content': content,
  }, token: token);

  Future<void> reportCommunityPost({
    required String token,
    required String postId,
    required String reason,
  }) => _post('community/posts/$postId/reports', {
    'reason': reason,
  }, token: token).then((_) {});

  Future<List<Map<String, dynamic>>> followedTeams(String token) =>
      _getCollection('account/follows', const {}, token: token);

  Future<void> followTeam({
    required String token,
    required String teamId,
    required bool follow,
  }) => follow
      ? _put('account/follows/$teamId', const {}, token: token)
      : _delete('account/follows/$teamId', token: token);

  Future<Map<String, dynamic>> notificationPreferences(String token) =>
      _getObject('account/notification-preferences', token);

  Future<Map<String, dynamic>> saveNotificationPreferences({
    required String token,
    required Map<String, Object?> preferences,
  }) => _put('account/notification-preferences', preferences, token: token);

  /// Creates a translation session. A speech provider must be configured by
  /// the backend before an audio stream can be started.
  Future<Map<String, dynamic>> createTranslationSession({
    String sourceLanguage = 'en',
    String targetLanguage = 'lg',
    String audioFormat = 'webm',
  }) => _post('translation/sessions', {
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'audioFormat': audioFormat,
  });

  Future<List<Map<String, dynamic>>> _getCollection(
    String path,
    Map<String, String> query, {
    String? token,
  }) async {
    final uri = Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path')
        .replace(queryParameters: query);
    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 12));
    final body = _decode(response);
    final data = body['data'];
    if (data is! List || data.any((item) => item is! Map<String, dynamic>)) {
      throw const AfconApiException(
        200,
        'invalid_response',
        'The AFCON service returned an unexpected collection.',
      );
    }
    return data.cast<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> payload, {
    String? token,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _getObject(String path, String token) async {
    final response = await _client
        .get(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 12));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _patch(
    String path,
    Map<String, Object?> payload, {
    required String token,
  }) async {
    final response = await _client
        .patch(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 12));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, Object?> payload, {
    required String token,
  }) async {
    final response = await _client
        .put(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 12));
    return _decode(response);
  }

  Future<void> _delete(String path, {required String token}) async {
    final response = await _client
        .delete(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 204) return;
    _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AfconApiException(
        response.statusCode,
        body['error']?.toString() ?? 'request_failed',
        body['message']?.toString() ?? 'The AFCON service is unavailable.',
      );
    }
    return body;
  }

  void close() => _client.close();
}

class AfconApiException implements Exception {
  const AfconApiException(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'AfconApiException($statusCode, $code): $message';
}
