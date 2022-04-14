import 'dart:convert';

import 'package:dio/dio.dart';

/// Requests base url
const String _baseUrl = 'https://api.mail.tm';

/// Dio client
late final Dio _dio = Dio(BaseOptions(
  baseUrl: _baseUrl,
  contentType: 'application/json',
  validateStatus: (int? status) => (status ?? 400) < 500,
));

/// Client's exception class.
/// If you want to see what corresponds to the error codes see [Requests.request]
class MailException implements Exception {
  final String message;
  final int code;

  MailException(this.message, this.code);

  @override
  String toString() => code.toString() + ': ' + message;
}

/// Class for handling requests.
class Requests {
  /// get requests
  /// Accepts only headers (optional)
  static Future<T> get<T>(String endpoint, [Map<String, String>? headers]) =>
      request<T>(endpoint, 'GET', headers: headers);

  /// post requests
  /// Accepts only the data (body) of the request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, String> data,
  ) =>
      request<Map<String, dynamic>>(endpoint, 'POST', data: data);

  /// patch requests
  /// Accepts only the headers
  static Future<bool> patch(
    String endpoint,
    Map<String, String> headers,
  ) async {
    await request(endpoint, 'PATCH', headers: headers);
    return true;
  }

  /// delete requests
  /// Accepts only the headers.
  static Future<bool> delete(
    String endpoint,
    Map<String, String> headers,
  ) async =>
      request<bool>(endpoint, 'DELETE', headers: headers);

  /// request method for handling requests.
  /// Accepts the endpoint, method and optional headers and data.
  static Future<T> request<T>(
    String endpoint,
    String method, {
    Map<String, String>? data,
    Map<String, String>? headers,
  }) async {
    headers ??= {};
    headers['Accept'] = 'application/json';
    Response response;
    int statusCode;
    do {
      try {
        response = await _dio.request(
          endpoint,
          data: data,
          options: Options(method: method, headers: headers),
        );
        statusCode = response.statusCode ?? 0;
        if (statusCode == 429) {
          await Future.delayed(Duration(seconds: 1));
        }
      } on DioError catch (e) {
        int? statusCode = e.response?.statusCode;
        String? message = e.response?.statusMessage ?? e.message;

        throw MailException(message, statusCode ?? 0);
      }
    } while (statusCode == 429);

    if (response.data == '') {
      throw MailException('No data', response.statusCode ?? 0);
    }

    if (T == bool && method == 'DELETE') {
      response.data = response.statusCode == 204;
    }
    if (response.data is String && T != String && T != bool) {
      response.data = jsonDecode(response.data.toString());
    }

    if (response.statusCode == 400) {
      throw MailException('Invalid input', 400);
    } else if (response.statusCode == 401) {
      throw MailException('Invalid credentials.', 401);
    } else if (response.statusCode == 404) {
      throw MailException('Resource not found', 404);
    } else if (response.statusCode == 422) {
      throw MailException('Unprocessable Entity', 422);
    } else if (response.statusCode == 429) {
      throw MailException('Resource already exists', 429);
    } else if ((response.statusCode ?? 400) >= 400) {
      throw MailException('Unknown error.', response.statusCode ?? 0);
    }
    if (response.data == Map) {
      return response.data ?? {} as T;
    } else if (response.data == List) {
      return response.data ?? [] as T;
    }
    return response.data as T;
  }
}
