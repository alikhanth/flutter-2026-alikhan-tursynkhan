import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(host, path, queryParameters);
    final response = await _send(() => _client.get(uri, headers: _headers));
    _check(response);
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
    int expectedStatus = 201,
  }) async {
    final uri = Uri.https(host, path);
    final response = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(response, expectedStatus: expectedStatus);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url} -> ${response.statusCode}',
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
