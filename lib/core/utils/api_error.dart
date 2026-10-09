import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A server / network error turned into something a person can read.
class ApiError {
  final String title;
  final String message;
  const ApiError(this.title, this.message);
}

/// Decodes backend error bodies such as
/// `{error: {code: VALIDATION_ERROR, message: "...", field_errors: {}, request_id: "..."}}`
/// into a short title + clean message (no codes, no request ids).
ApiError describeApiError(Object e, {String? fallbackTitle}) {
  if (e is! DioException) {
    return ApiError(fallbackTitle ?? 'Something went wrong',
        'Something went wrong. Please try again.');
  }

  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return const ApiError('No connection',
        'Could not reach the server. Please check your internet and try again.');
  }

  final status = e.response?.statusCode;
  final data = e.response?.data;

  String? code;
  String? message;
  final lines = <String>[];

  if (data is Map) {
    // Some backends wrap everything inside "error": {...}
    Map root = data;
    if (data['error'] is Map) root = data['error'] as Map;

    code = root['code']?.toString();
    for (final k in const ['message', 'detail', 'error']) {
      final v = root[k];
      if (v is String && v.trim().isNotEmpty) {
        message = v.trim();
        break;
      }
    }

    final rid = root['request_id'] ?? data['request_id'];
    if (rid != null) debugPrint('🧾 [API] request_id=$rid code=$code');

    // field_errors: {"latitude": ["This field is required."]}
    final fe = root['field_errors'];
    if (fe is Map && fe.isNotEmpty) {
      fe.forEach((k, v) {
        final txt = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
        lines.add('${_label(k.toString())}: $txt');
      });
    }

    // DRF style body: {"latitude": ["..."]}
    if (message == null && lines.isEmpty) {
      for (final entry in root.entries) {
        if (const ['code', 'request_id', 'field_errors'].contains(entry.key)) {
          continue;
        }
        final v = entry.value;
        final txt = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
        lines.add('${_label(entry.key.toString())}: $txt');
      }
    }
  } else if (data is String && data.isNotEmpty && data.length < 200) {
    message = data;
  }

  var text = message ?? '';
  if (lines.isNotEmpty) {
    text = text.isEmpty ? lines.join('\n') : '$text\n${lines.join('\n')}';
  }
  if (text.isEmpty) {
    text = 'Something went wrong (code ${status ?? '-'}). Please try again.';
  }

  return ApiError(_titleFor(code, status, fallbackTitle), _polish(text));
}

String _titleFor(String? code, int? status, String? fallback) {
  switch ((code ?? '').toUpperCase()) {
    case 'VALIDATION_ERROR':
      return fallback ?? 'Please check this';
    case 'PERMISSION_DENIED':
    case 'FORBIDDEN':
      return 'Not allowed';
    case 'NOT_FOUND':
      return 'Not found';
    case 'UNAUTHORIZED':
    case 'AUTHENTICATION_FAILED':
    case 'NOT_AUTHENTICATED':
      return 'Session expired';
  }
  if (status == 403) return 'Not allowed';
  if (status == 404) return 'Not found';
  if (status == 401) return 'Session expired';
  if (status != null && status >= 500) return 'Server problem';
  return fallback ?? 'Something went wrong';
}

String _label(String key) {
  final s = key.replaceAll('_', ' ').trim();
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Turns "between 16:07 and 16:08." into "between 4:07 PM and 4:08 PM."
/// and makes sure the sentence ends with punctuation.
String _polish(String text) {
  var out = text.trim();
  if (out.toLowerCase().contains('between')) {
    out = out.replaceAllMapped(RegExp(r'\b([01]?\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?\b'),
        (m) {
      final h = int.parse(m.group(1)!);
      final min = m.group(2)!;
      final suffix = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12:$min $suffix';
    });
  }
  if (!RegExp(r'[.!?]$').hasMatch(out)) out = '$out.';
  return out;
}
