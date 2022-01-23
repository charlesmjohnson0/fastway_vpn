import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fastway/api/api_models.dart';
import 'package:fastway/models/vpn_model.dart';

import 'http.dart';

class Api {
  // static final Api _instance = Api._internal();
  // factory Api() {
  //   return _instance;
  // }

  // Api._internal() {
  //   init();
  // }

  final Http _http = Http();

  Api();

  String? deviceId;
  VoidCallback? onErrorCallback;

  void configure(
      {required baseUrl,
      required String deviceId,
      connectTimeout = 10000,
      receiveTimeout = 10000,
      // Iterable<InterceptorsWrapper>? interceptorsWrappers,
      VoidCallback? onErrorCallback}) {
    this.deviceId = deviceId;
    _http.configure(
        baseUrl, connectTimeout, receiveTimeout, requestInterceptors());
    this.onErrorCallback = onErrorCallback;
  }

  List<InterceptorsWrapper> requestInterceptors() {
    InterceptorsWrapper interceptorsWrapper =
        InterceptorsWrapper(onRequest: (options, handler) async {
      // debugPrint('request url : ${options.uri}');
      // debugPrint('request data : ${options.data}');

      options.headers.putIfAbsent('DID', () => deviceId);

      handler.next(options);
    }, onResponse: (response, handler) {
      // debugPrint('response data : ${response.data}');

      handler.next(response);
    }, onError: (error, handler) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          onErrorCallback!.call();
          break;
        case DioErrorType.response:
        case DioErrorType.other:
        case DioErrorType.cancel:
        default:
      }

      // debugPrint('process error : $error');

      handler.next(error);
    });

    return [interceptorsWrapper];
  }

  Future<BaseResponse> ping() async {
    try {
      var response = await _http.get('/public/ping');

      return BaseResponse(code: response.data['code']);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse<List<ApiServerModel>>> apiServerFindAll() async {
    try {
      var response = await _http.get('/api/servers');

      var code = response.data['code'];
      List<ApiServerModel> result = [];

      if (response.data['result'] != null) {
        var list = response.data['result'] as List;
        result = list.map((e) => ApiServerModel.fromJson(e)).toList();
      }

      return BaseResponse(code: code, result: result);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse<List<CityModel>>> citiesFindAll() async {
    try {
      Response response = await _http.get('/api/cities');

      var code = response.data['code'];
      List<CityModel> result = [];

      if (response.data['result'] != null) {
        var list = response.data['result'] as List;
        result = list.map((e) => CityModel.fromJson(e)).toList();
      }

      return BaseResponse(code: code, result: result);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse<NodeModel>> nodeFind(
      {int? cityId, VpnProtocol? protocol}) async {
    try {
      Response response = await _http.get('/api/node',
          params: {'cityId': cityId, 'protocol': protocol!.index});

      var code = response.data['code'];

      NodeModel? result;

      if (response.data['result'] != null) {
        result = NodeModel.fromJson(response.data['result']);
      }

      return BaseResponse(code: code, result: result);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse<ExchangeCodeModel>> codeInfo(String deviceId) async {
    try {
      Response response =
          await _http.get('/api/codes', params: {'deviceId': deviceId});

      var code = response.data['code'];
      ExchangeCodeModel? result;

      if (response.data['result'] != null) {
        result = ExchangeCodeModel.fromJson(response.data['result']);
      }

      return BaseResponse(code: code, result: result);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse<ExchangeCodeModel>> codeBind(
      String exchangeCode, DeviceModel device) async {
    try {
      Response response = await _http.put('/api/codes/:code',
          pathParams: {'code': exchangeCode}, params: device);

      var code = response.data['code'];

      ExchangeCodeModel? result;

      if (response.data['result'] != null) {
        result = ExchangeCodeModel.fromJson(response.data['result']);
      }

      return BaseResponse(code: code, result: result);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse> codeUnBind(
      String exchangeCode, DeviceModel device) async {
    try {
      Response response = await _http.delete('/api/codes/:code',
          pathParams: {'code': exchangeCode}, params: device);

      var code = response.data['code'];
      // var result = response.data['result'];

      return BaseResponse(code: code);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }

  Future<BaseResponse> reportError(
      String deviceId, String platform, String error, String stackTrack) async {
    try {
      Response response = await _http.post('/api/exceptions', params: {
        'deviceId': deviceId,
        'platform': platform,
        'error': error,
        'stackTrack': stackTrack
      });

      var code = response.data['code'];

      return BaseResponse(code: code);
    } on DioError catch (e) {
      return BaseResponse(code: 0, error: e);
    }
  }
}
