import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.data});

  final String message;

  final int? statusCode;

  final Object? data;

  String? get code {
    final cuerpo = data;
    return cuerpo is Map ? cuerpo['code']?.toString() : null;
  }

  bool get isUnauthorized => statusCode == 401;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

class SessionException extends ApiException {
  const SessionException([super.message = 'No hay una sesión activa. Inicia sesión de nuevo.']);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No se pudo conectar con el servidor. Revisa tu conexión a internet.']);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([super.message = 'El servidor tardó demasiado en responder. Intenta de nuevo.']);
}

class ApiParseException extends ApiException {
  const ApiParseException(super.message, {super.statusCode, super.data});
}

class ApiService {
  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
    this.enableLogs = kDebugMode,
    this.onUnauthorized,
  }) : _client = client ?? clientePorDefecto ?? http.Client();

  static http.Client? clientePorDefecto;

  final String baseUrl;
  final Duration timeout;
  final bool enableLogs;

  final VoidCallback? onUnauthorized;

  final http.Client _client;

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Uri _buildUrl(String path, [Map<String, dynamic>? queryParameters]) {
    final base = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    final params = <String, String>{
      for (final entry in (queryParameters ?? const <String, dynamic>{}).entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };

    return Uri.parse('$base/$normalizedPath').replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _send('GET', _buildUrl(path, queryParameters), headers: headers);

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('POST', _buildUrl(path), body: body, headers: headers);

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('PUT', _buildUrl(path), body: body, headers: headers);

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('DELETE', _buildUrl(path), body: body, headers: headers);

  Future<dynamic> _send(
    String method,
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final request = http.Request(method, url)..headers.addAll(_buildHeaders(headers));
    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }

    _log('→ $method $url');

    final http.Response response;
    try {
      response = await _client.send(request).then(http.Response.fromStream).timeout(timeout);
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on http.ClientException {
      throw const NetworkException();
    }

    _log('← ${response.statusCode} $url');

    final data = _decodeBody(response.bodyBytes);
    final rechazada = data is Map && data['success'] == false;
    if (response.statusCode < 200 || response.statusCode >= 300 || rechazada) {
      if (response.statusCode == 401) {
        onUnauthorized?.call();
      }
      throw ApiException(
        _errorMessage(response.statusCode, data),
        statusCode: response.statusCode,
        data: data,
      );
    }
    return data;
  }

  Object? _decodeBody(List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return text;
    }
  }

  void _log(String message) {
    if (enableLogs) {
      debugPrint('[ApiService] $message');
    }
  }
}

String _errorMessage(int statusCode, Object? data) {
  if (data is Map) {
    for (final key in const ['message', 'mensaje', 'title', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }

    final errors = data['errors'];
    if (errors is Map) {
      final messages = [
        for (final value in errors.values)
          for (final item in value is List ? value : [value])
            if (item is String && item.trim().isNotEmpty) item.trim(),
      ];
      if (messages.isNotEmpty) return messages.join(' ');
    }
  }

  if (data is String && data.trim().isNotEmpty) return data.trim();

  return switch (statusCode) {
    400 => 'Los datos enviados no son válidos.',
    401 => 'Tu sesión venció. Vuelve a iniciar sesión.',
    403 => 'No tienes permiso para hacer esto.',
    404 => 'No se encontró lo que buscas.',
    409 => 'Ya existe un registro con esos datos.',
    >= 500 => 'El servidor tuvo un problema. Intenta de nuevo en un momento.',
    _ => 'Error $statusCode al consultar la API.',
  };
}
