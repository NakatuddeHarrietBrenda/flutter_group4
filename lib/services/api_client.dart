import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'https://testing.rasmuspharmaceuticals.com';
  final http.Client _client = http.Client();

  // GET Request with Timeout, Error Handling and Auth Token
  Future<dynamic> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _client.get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Please verify your data or Wi-Fi settings.');
    } on TimeoutException {
      throw ApiException('The server is taking too long to respond. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      final errorStr = e.toString();
      if (kIsWeb && errorStr.contains('Failed to fetch')) {
        throw ApiException(
          'Web Security (CORS) Block. To resolve this during local development, restart your Flutter app in Chrome with CORS disabled:\n\n'
          'flutter run -d chrome --web-browser-flag "--disable-web-security"'
        );
      }
      throw ApiException('Unexpected network error occurred: $errorStr');
    }
  }

  // POST Request with Timeout, JSON encoding and Auth Token
  Future<dynamic> post(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Unable to transmit request.');
    } on TimeoutException {
      throw ApiException('Checkout request timed out. Please verify connectivity.');
    } catch (e) {
      if (e is ApiException) rethrow;
      final errorStr = e.toString();
      if (kIsWeb && errorStr.contains('Failed to fetch')) {
        throw ApiException(
          'Web Security (CORS) Block during POST request. To resolve this during local development, restart your Flutter app in Chrome with CORS disabled:\n\n'
          'flutter run -d chrome --web-browser-flag "--disable-web-security"'
        );
      }
      throw ApiException('Failed to submit data: $errorStr');
    }
  }

  // Process HTTP response and return JSON maps/lists or throw exceptions
  dynamic _processResponse(http.Response response) {
    final int code = response.statusCode;
    
    if (code >= 200 && code < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to parse server response.', code);
      }
    } else if (code == 404) {
      throw ApiException('Requested resource not found on server.', 404);
    } else if (code >= 500) {
      throw ApiException('Server error occurred (${code}). Please try again later.', code);
    } else {
      // Decode details if available
      String message = 'API operation failed with code: $code';
      try {
        final parsed = jsonDecode(response.body);
        if (parsed['message'] != null) {
          message = parsed['message'];
        }
      } catch (_) {}
      throw ApiException(message, code);
    }
  }
}
