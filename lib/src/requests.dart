import 'dart:convert';

import 'package:dio/dio.dart';

import 'MailTm.dart';

class Requests {
  ///Makes a post request using the given [endpoint] on the account
  ///[address] and [password]
  ///[error] is the error message to throw if the request fails
  ///[codes] is the list of status codes to accept

  static Future<Map<String, dynamic>> postRequestAccount(
    String endpoint,
    address,
    password, {
    String? error,
    List<int>? codes,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/ld+json',
    };
    var response = await Dio().post(
      "${MailTm.apiAddress}/$endpoint",
      data: {
        'address': address,
        'password': password,
      },
      options: Options(headers: headers),
    );
    if (!(codes ?? [200, 201]).contains(response.statusCode))
      throw Exception(error ?? 'Error doing request.');
    if (response.data is String) response.data = jsonDecode(response.data);
    return Map<String, dynamic>.from(response.data);
  }

  ///Makes a get request using the given [endpoint]
  ///[error] is the error message to throw if the request fails
  ///[codes] is the list of status codes to accept
  static Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, dynamic>? params,
    String? error,
    List<int>? codes,
    Map<String, dynamic>? headers,
  }) async {
    var response = await Dio().get(
      "${MailTm.apiAddress}/$endpoint",
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (!(codes ?? [200, 201]).contains(response.statusCode))
      throw Exception(error ?? 'Error doing request.');

    return jsonDecode(response.data);
  }

  ///Deletes the account by doing a DELETE request to the API
  static Future<int> delete(
    String endpoint,
    Map<String, dynamic> headers,
  ) async {
    var response = await Dio().delete(
      "${MailTm.apiAddress}/$endpoint",
      options: Options(headers: headers),
    );
    return response.statusCode ?? 404;
  }
}
