import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vpn/api/api_models.dart';
import 'package:vpn/models/vpn_model.dart';

import 'http.dart';

class Api {
  // static final Api _instance = Api._internal();
  // factory Api() {
  //   return _instance;
  // }

  // Api._internal() {
  //   init();
  // }

  static const int sucCode = 200;
  final Http _http = Http();

  Api();

  static bool isSuc(int code) {
    return sucCode == code;
  }

  void configure(baseUrl,
      [connectTimeout = 10000,
      receiveTimeout = 10000,
      Iterable<InterceptorsWrapper>? interceptorsWrappers]) {
    _http.configure(
        baseUrl, connectTimeout, receiveTimeout, requestInterceptors());
  }

  List<InterceptorsWrapper> requestInterceptors() {
    InterceptorsWrapper interceptorsWrapper =
        InterceptorsWrapper(onRequest: (options, handler) async {
      debugPrint('request url : ${options.uri}');
      debugPrint('request data : ${options.data}');

      handler.next(options);
    }, onResponse: (response, handler) {
      debugPrint('response data : ${response.data}');

      handler.next(response);
    }, onError: (error, handler) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          break;
        case DioErrorType.response:
        case DioErrorType.other:
        case DioErrorType.cancel:
        default:
      }

      debugPrint('process error : $error');

      handler.next(error);
    });

    return [interceptorsWrapper];
  }

  Future ping() async {
    var response = await _http.get('/public/ping');

    return response.data;
  }

  Future apiServerFindAll() async {
    var response = await _http.get('/api/servers');

    return response.data;
  }

  Future citiesFindAll() async {
    Response response = await _http.get('/api/cities');

    return response.data;
  }

  Future nodeFind({int? cityId, VpnProtocol? protocol}) async {
    Response response = await _http.get('/api/node',
        params: {'cityId': cityId, 'protocol': protocol!.index});

    return response.data;
  }

  Future nodesFindAll({int? cityId}) async {
    var params = {};

    if (cityId != null) {
      params = {'cityId': cityId};
    }

    Response response = await _http.get('/api/nodes', params: params);
    return response.data;
  }

  Future codeInfo(String deviceId) async {
    Response response =
        await _http.get('/api/codes', params: {'deviceId': deviceId});

    // var baseResponse = response.data;
    //
    // if (Api.isSuc(baseResponse['code'])) {
    //   var result = baseResponse['result'];
    //
    //   CodeModel codeModel = CodeModel.fromJson(result);
    //
    // }

    return response.data;
  }

  Future codeBind(String code, DeviceModel device) async {
    var response = await _http.put('/api/codes/:code',
        pathParams: {'code': code}, params: device);

    return response.data;
  }

  Future codeUnBind(String code, DeviceModel device) async {
    var response = await _http.delete('/api/codes/:code',
        pathParams: {'code': code}, params: device);

    return response.data;
  }

  Future countriesFindAll() async {
    Response response = await _http.get('public/countries');
    return response.data;
  }
}
