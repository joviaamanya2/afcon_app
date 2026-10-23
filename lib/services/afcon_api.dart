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

  Future<Map<String, dynamic>> askAssistant({
    required String question,
    String language = 'en',
  }) => _post('assistant/ask', {'question': question, 'language': language});

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
    Map<String, String> query,
  ) async {
    final uri = Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path')
        .replace(queryParameters: query);
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    final body = _decode(response);
    final data = body['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> payload,
  ) async {
    final response = await _client
        .post(
          Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
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
