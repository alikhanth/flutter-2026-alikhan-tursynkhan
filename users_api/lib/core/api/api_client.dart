import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> _headers([Map<String, String>? extra]) async {
    return {
      'Accept': 'application/json',
      if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
      ...?extra,
    };
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(host, path, queryParameters);
    final headers = await _headers();

    final response = await _send(() => _client.get(uri, headers: headers));

    _check(response);
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
    int expectedStatus = 201,
  }) async {
    final uri = Uri.https(host, path);
    final headers = await _headers({'Content-Type': 'application/json'});

    final response = await _send(
      () => _client.post(uri, headers: headers, body: jsonEncode(body)),
    );

    _check(response, expectedStatus: expectedStatus);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        log(
          '${response.request?.method} '
          '${response.request?.url} -> ${response.statusCode}',
          name: 'api',
        );
      }

      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r, {int? expectedStatus}) {
    if (r.statusCode == 401) {
      throw const UnauthorizedException();
    }

    if (r.statusCode == 404) {
      throw const NotFoundException();
    }

    if (r.statusCode >= 500) {
      throw ServerException(r.statusCode);
    }

    if (expectedStatus != null && r.statusCode != expectedStatus) {
      throw BadResponseException(
        'Expected HTTP $expectedStatus, got ${r.statusCode}',
      );
    }

    if (r.statusCode >= 400) {
      throw BadResponseException('HTTP ${r.statusCode}');
    }
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('Malformed JSON: ${e.message}');
    }
  }
}
