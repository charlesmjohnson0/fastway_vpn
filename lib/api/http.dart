import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';

class Http {
  late BaseOptions _options;
  late Iterable<InterceptorsWrapper>? interceptorsWrappers = [];

  configure(baseUrl,
      [connectTimeout = 10000,
      receiveTimeout = 10000,
      Iterable<InterceptorsWrapper>? interceptorsWrappers]) {
    _options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: "application/json");

    this.interceptorsWrappers = interceptorsWrappers;
  }

  get(url, {pathParams, params, needCode = false, cancelToken}) async {
    return await request(
        url, pathParams, params, 'GET', null, needCode, cancelToken);
  }

  post(url, {pathParams, params, needCode = false, cancelToken}) async {
    return await request(
        url, pathParams, params, 'POST', null, needCode, cancelToken);
  }

  put(url, {pathParams, params, needCode = false, cancelToken}) async {
    return await request(
        url, pathParams, params, 'PUT', null, needCode, cancelToken);
  }

  delete(url, {pathParams, params, needCode = false, cancelToken}) async {
    return await request(
        url, pathParams, params, 'DELETE', null, needCode, cancelToken);
  }

  Future<Response<Map<String, dynamic>>> request(
      url, pathParams, params, method, header, needCode, cancelToken) async {
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        if (url.indexOf(key) != -1) {
          url = url.replaceAll(":$key", value.toString());
        }
      });
    }

    if (params != null && method == 'GET') {
      url += '?';
      params.forEach((key, value) {
        url += '$key=$value&';
      });
    }

    Map headers = {};

    if (header != null) {
      headers.addAll(header);
    }

    _options.headers = Map<String, dynamic>.from(headers);

    Dio _dio = Dio(_options);
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    _dio.interceptors.addAll(interceptorsWrappers!);

    late Response<Map<String, dynamic>> response;

    try {
      response = await _dio.request(url,
          data: params,
          options: Options(method: method),
          cancelToken: cancelToken);
    } on DioError catch (e) {
      debugPrint('process error : $e');
      rethrow;
    }

    return response;
  }
}
