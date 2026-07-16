import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

void appPrint(dynamic message) {
  if (kDebugMode) {
    print("[PRINT] [Tmingle] => $message");
  }
}

void appLog(dynamic message) {
  if (kDebugMode) {
    log("[LOG] [Tmingle] => $message");
  }
}

/// Attempts to pretty-print a JSON string with 2-space indentation.
/// Falls back to the raw string if it is not valid JSON.
String prettyJson(String rawJson) {
  try {
    final decoded = jsonDecode(rawJson);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return rawJson;
  }
}

/// Logs a network response in a clean, Postman-style format.
/// Uses [debugPrint] which handles long strings by auto-chunking,
/// preventing the log from being truncated or split by the VM service.
void logResponse({
  required String method,
  required String url,
  required int statusCode,
  required String body,
}) {
  if (!kDebugMode) return;
  final separator = '─' * 60;
  final buffer = StringBuffer();
  buffer.writeln('\n$separator');
  buffer.writeln('  $method  $url  [$statusCode]');
  buffer.writeln(separator);
  buffer.writeln(prettyJson(body));
  buffer.write(separator);
  debugPrint(buffer.toString());
}
