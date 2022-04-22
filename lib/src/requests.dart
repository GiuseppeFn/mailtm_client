import 'dart:convert';
import 'dart:typed_data';

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
  final String? message;
  final int? code;

  MailException([this.message = 'Unknown error.', this.code = 0]);

  @override
  String toString() =>
      (code ?? 0).toString() + ': ' + (message ?? 'Unknown error.');
}

/// Class for handling requests.
class Requests {
  /// get requests
  /// Accepts only headers (optional)
  static Future<T> get<T>(
    String endpoint, [
    Map<String, String>? headers,
    bool json = true,
  ]) =>
      request<T>(endpoint, 'GET', headers: headers, json: json);

  /// post requests
  /// Accepts only the data (body) of the request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, String> data,
  ) =>
      request<Map<String, dynamic>>(endpoint, 'POST', data: data);

  /// patch requests
  /// Accepts only the headers
  static Future<bool> patch(String endpoint, Map<String, String> headers) =>
      request(endpoint, 'PATCH', headers: headers);

  /// delete requests
  /// Accepts only the headers.
  static Future<bool> delete(String endpoint, Map<String, String> headers) =>
      request<bool>(endpoint, 'DELETE', headers: headers);

  /// Downloads a file as Uint8List
  static Future<Uint8List> download(
    String endpoint,
    Map<String, String> headers,
  ) =>
      request(
        endpoint,
        'GET',
        headers: headers,
        responseType: ResponseType.bytes,
      );

  /// request method for handling requests.
  /// Accepts the endpoint, method and optional headers and data.
  static Future<T> request<T>(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    Map<String, String>? data,
    ResponseType? responseType,
    bool json = true,
  }) async {
    headers ??= {};
    headers['Accept'] = json ? 'application/json' : 'application/ld+json';
    Response response;
    int statusCode;
    do {
      try {
        response = await _dio.request(
          endpoint,
          data: data,
          options: Options(
            method: method,
            headers: headers,
            responseType: responseType,
          ),
        );
        statusCode = response.statusCode ?? 400;
        if (statusCode == 429) {
          await Future.delayed(Duration(seconds: 1));
        }
      } on DioError catch (e) {
        throw MailException(
          e.response?.statusMessage ?? e.message,
          e.response?.statusCode,
        );
      }
    } while (statusCode == 429);

    switch (statusCode) {
      case 400:
        throw MailException('Invalid input', 400);
      case 401:
        throw MailException('Invalid credentials.', 401);
      case 404:
        throw MailException('Resource not found', 404);
      case 422:
        throw MailException('Unprocessable Entity', 422);
      case 429:
        throw MailException('Resource already exists', 429);
      default:
        if (statusCode < 200 && statusCode > 204) {
          throw MailException(response.statusMessage, statusCode);
        }
        break;
    }

    if (method == 'DELETE' || method == 'PATCH') {
      response.data = (statusCode == 204 || statusCode == 200);
    }
    if (response.data is String) {
      response.data = jsonDecode(response.data.toString());
    }
    return response.data as T;
  }
}
