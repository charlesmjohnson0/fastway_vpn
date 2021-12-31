import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import '/api/api.dart';
import '/api/api_models.dart';
import '../models/vpn_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fy_vpn_sdk/fy_vpn_sdk.dart';

enum DeviceType { android, iOS, windows, macOS, linux, error }

class Global {
  Global._internal();

  static final Global _global = Global._internal();

  factory Global() {
    return _global;
  }

  String? _version;
  String get versionInfo => _version ?? 'Version 2.0.1';
  String? _copyright;
  String get copyrightInfo => _copyright ?? '';

  static const String _languageKey = 'LANGUAGE';
  static const String _connectionProtocolKey = 'CONNECTION_PROTOCOL';
  static const String _exchangeCodeKey = 'EXCHANGE_CODE';
  static const String _apiServersKey = 'API_SERVERS';
  static const String _citiesKey = 'CITIES';
  static const String _baseUrlKey = 'BASE_URL';
  static const String _deviceKey = 'DEVICE';

  final FyVpnSdk _sdk = FyVpnSdk();

  String? defaultApiBaseUrl;

  Future<void> setBaseUrl(String? url) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (url == null) {
      _prefs.remove(_baseUrlKey);
      return;
    }

    if (url.startsWith("http://") || url.startsWith("https://")) {
      _prefs.setString(_baseUrlKey, url);
    }
  }

  Future<String?> getBaseUrl() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(_baseUrlKey);
  }

  ExchangeCodeModel? _exchangeCode;
  // late String _deviceId;
  late Map<String, dynamic> _device;

  String get userName => deviceId;
  String get deviceId => _device['deviceId'];
  DeviceType get platform => DeviceType.values
      .firstWhere((element) => element.index == _device['platform']);

  String? get password => _exchangeCode!.code;

  Future<ExchangeCodeModel?> getExchangeCode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? exchangeCodeStr = _prefs.getString(_exchangeCodeKey);

    if (exchangeCodeStr == null) {
      return null;
    }
    _exchangeCode = ExchangeCodeModel.fromJson(jsonDecode(exchangeCodeStr));
    return _exchangeCode;
  }

  Future<void> setExchangeCode(ExchangeCodeModel? exchangeCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (exchangeCode == null) {
      _prefs.remove(_exchangeCodeKey);
    } else {
      _prefs.setString(_exchangeCodeKey, jsonEncode(exchangeCode.toJson()));
    }
    _exchangeCode = exchangeCode;
  }

  VpnProtocol _connectionProtocol = VpnProtocol.auto;
  VpnProtocol get protocol => _connectionProtocol;

  Locale _locale = const Locale("en");
  Locale get locale => _locale;

  Api? _api;
  Api? get api => _api;

  ApiServerModel? _apiServerModel;
  ApiServerModel? get apiServerModel => _apiServerModel;

  CityModel? _city;
  CityModel? get city => _city;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> initPlatformState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey(_deviceKey)) {
      String deviceStr = (_prefs.getString(_deviceKey))!;
      _device = jsonDecode(deviceStr);
    } else {
      try {
        if (Platform.isAndroid) {
          String deviceId = await _sdk.deviceId;
          _device = {
            'deviceId': deviceId,
            'platform': DeviceType.android.index
          };
        } else if (Platform.isIOS) {
          String deviceId = await _sdk.deviceId;
          _device = {'deviceId': deviceId, 'platform': DeviceType.iOS.index};
        } else if (Platform.isWindows) {
          _device = {
            'deviceId': getRandomString(24),
            'platform': DeviceType.windows.index
          };
        } else if (Platform.isMacOS) {
          _device = {
            'deviceId': getRandomString(16),
            'platform': DeviceType.macOS.index
          };
        }
      } on PlatformException {
        _device = {
          'deviceId': getRandomString(14),
          'platform': DeviceType.error.index
        };
      }

      _prefs.setString(_deviceKey, jsonEncode(_device));
    }
  }

  Future<void> init(
      {required String baseApiUrl,
      required String copyrightInfo,
      required String versionInfo}) async {
    defaultApiBaseUrl = baseApiUrl;
    _copyright = copyrightInfo;
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    await initPlatformState();

    //language set
    String? language = _prefs.getString(_languageKey);
    if (language != null &&
        language.isNotEmpty &&
        language.toLowerCase() != 'auto') {
      _locale = Locale(language);
    }

    int? connectProtocol = _prefs.getInt(_connectionProtocolKey);

    if (connectProtocol != null) {
      _connectionProtocol = VpnProtocol.values[connectProtocol];
    }
  }

  Future<int> initApi() async {
    //get and refresh api servers
    _api = await _getAvailableApi();

    if (api == null) {
      return -1;
    }

    //refresh cities
    _refreshCities(_api!);

    //exchange code check
    await syncBindExchangeCode();

    return 0;
  }

  Future<bool> get isExchangeCodeValid async {
    if (_exchangeCode != null && _exchangeCode!.valid) {
      return true;
    }

    return false;
  }

  Future<ExchangeCodeModel?> syncBindExchangeCode() async {
    BaseResponse<ExchangeCodeModel> baseResponse =
        await _api!.codeInfo(deviceId);

    if (baseResponse.isSuc) {
      ExchangeCodeModel? exchangeCode = baseResponse.result;

      setExchangeCode(exchangeCode);

      return exchangeCode;
    } else {
      setExchangeCode(null);
    }

    return null;
  }

  Future<BaseResponse<ExchangeCodeModel>> bind(String exchangeCode) async {
    BaseResponse<ExchangeCodeModel> baseResponse =
        await _api!.codeBind(exchangeCode, DeviceModel(deviceId, platform));

    if (baseResponse.isSuc) {
      setExchangeCode(baseResponse.result);
    }

    return baseResponse;
  }

  Future<BaseResponse?> unbind(DeviceModel? device) async {
    ExchangeCodeModel? code = await getExchangeCode();

    if (code == null) {
      return null;
    }

    device ??= DeviceModel(deviceId, platform);

    // Future.delayed(const Duration(seconds: 5))
    //     .then((value) => syncBindExchangeCode());

    return _api!.codeUnBind(code.code, device);
  }

  Future<List<CityModel>?> getAllCities() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    var stringList = _prefs.getStringList(_citiesKey);

    if (stringList == null || stringList.isEmpty) {
      await _refreshCities(_api!);
    }
    return stringList!.map((e) => CityModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _refreshCities(Api api) async {
    BaseResponse<List<CityModel>> baseResponse = await api.citiesFindAll();

    if (baseResponse.isSuc) {
      List<CityModel> cities = baseResponse.result ?? [];

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setStringList(_citiesKey,
          cities.map((e) => jsonEncode(e.toJson()).toString()).toList());
    }
  }

  Future<void> _refreshApiServers(Api api) async {
    BaseResponse<List<ApiServerModel>> response = await api.apiServerFindAll();

    if (response.isSuc) {
      List<ApiServerModel> apiServers = response.result ?? [];

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setStringList(
          _apiServersKey,
          apiServers
              .map((e) => e.toJson())
              .toList()
              .map((e) => jsonEncode(e))
              .toList());
    }
  }

  Future<Api?> _getAvailableApi() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    var baseUrl = await getBaseUrl();

    Api api = Api();

    api.configure(
      baseUrl: baseUrl ?? defaultApiBaseUrl,
      deviceId: deviceId,
    );

    BaseResponse pong = await api.ping();

    if (pong.isSuc) {
      debugPrint('ping suc !');

      return api;
    } else {
      setBaseUrl(null);
    }

    var stringList = _prefs.getStringList(_apiServersKey);

    if (stringList == null) {
      return null;
    }

    List<ApiServerModel> list =
        stringList.map((e) => ApiServerModel.fromJson(jsonDecode(e))).toList();

    for (var apiServer in list) {
      Api api = Api();

      api.configure(
          baseUrl: apiServer.prefix,
          deviceId: deviceId,
          connectTimeout: 3000,
          receiveTimeout: 3000);

      BaseResponse pong = await api.ping();

      if (pong.isSuc) {
        debugPrint('set api : ${apiServer.prefix}');

        setBaseUrl(apiServer.prefix);

        _apiServerModel = apiServer;

        _refreshApiServers(api);
      } else {
        setBaseUrl(null);
      }
    }

    return null;
  }

  NodeModel? nodeModel;
  Future<void> changeLocation(CityModel? cityModel) async {
    _city = cityModel;
    nodeModel = null;
    findNode().then((value) => nodeModel = value);
  }

  Future<void> changeProtocol(VpnProtocol connectMode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs
        .setInt(_connectionProtocolKey, connectMode.index)
        .then((value) => _connectionProtocol = connectMode);
  }

  Future<void> changeLanguage(String language) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs
        .setString(_languageKey, language)
        .then((value) => _locale = Locale(language));
  }

  Future<NodeModel?> findNode() async {
    if (nodeModel != null) {
      if (_city == null || _city!.id == nodeModel!.city.id) {
        return nodeModel;
      }
    }

    int cityId = 0;

    if (_city != null) {
      cityId = _city!.id;
    }

    BaseResponse<NodeModel> response =
        await _api!.nodeFind(cityId: cityId, protocol: protocol);

    if (response.isSuc) {
      return response.result;
    }

    return null;
  }

  Future<void> reportError(Object e, StackTrace? stackTrace) async {
    _api!.reportError(
        deviceId, platform.toString(), e.toString(), stackTrace!.toString());
  }
}
