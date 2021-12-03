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
import 'package:device_info/device_info.dart';

enum DeviceType { android, iOS, windows, macOS, linux, error }

class Global {
  Global._internal();

  static final Global _global = Global._internal();

  factory Global() {
    return _global;
  }

  static const String versionInfo = 'Version 1.0.0(12345)';
  static const String copyrightInfo = 'Copyright xxx 2015-2021';
  static const String _languageKey = 'LANGUAGE';
  static const String _connectionProtocolKey = 'CONNECTION_PROTOCOL';
  static const String _exchangeCodeKey = 'EXCHANGE_CODE';
  static const String _apiServersKey = 'API_SERVERS';
  static const String _citiesKey = 'CITIES';
  static const String _baseUrlKey = 'BASE_URL';
  static const String _deviceKey = 'DEVICE';

  //TODO fixed on publish
  static String defaultApiBaseUrl = 'http://192.168.50.66:8080';

  Locale _locale = const Locale("en");
  ExchangeCodeModel? _exchangeCode;
  // late String _deviceId;
  late Map<String, dynamic> _device;

  String get userName => _device['deviceId'];
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

  fy_state _state = fy_state.NONE;
  Future<fy_state> get vpnState async {
    _state = await FyVpnSdk.state;
    return _state;
  }

  Locale get locale => _locale;

  Api? _api;
  Api? get api => _api;

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
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          _device = {
            'deviceId': androidInfo.androidId,
            'platform': DeviceType.android.index
          };
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          _device = {
            'deviceId': iosInfo.identifierForVendor,
            'platform': DeviceType.iOS.index
          };
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

  Future<void> init() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    initPlatformState();

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

    //get and refresh api servers
    _api = await _getAvailableApi();

    //refresh cities
    _refreshCities(_api!);

    //exchange code check
    await syncBindExchangeCode();
  }

  Future<bool> get isExchangeCodeValid async {
    if (_exchangeCode != null && _exchangeCode!.valid) {
      return true;
    }

    return false;
  }

  Future<ExchangeCodeModel?> syncBindExchangeCode() async {
    var baseResponse = await _api!.codeInfo(_device['deviceId']);

    if (Api.isSuc(baseResponse['code'])) {
      Map<String, dynamic> result =
          baseResponse['result'] as Map<String, dynamic>;
      ExchangeCodeModel exchangeCode = ExchangeCodeModel.fromJson(result);

      setExchangeCode(exchangeCode);

      return exchangeCode;
    } else {
      setExchangeCode(null);
    }

    return null;
  }

  Future<ExchangeCodeModel?> bind(String exchangeCode) async {
    var baseResponse = await _api!.codeBind(
        exchangeCode,
        DeviceModel(
            _device['deviceId'],
            DeviceType.values.firstWhere(
                (element) => element.index == _device['platform'])));

    if (Api.isSuc(baseResponse['code'])) {
      Map<String, dynamic> result =
          baseResponse['result'] as Map<String, dynamic>;

      setExchangeCode(ExchangeCodeModel.fromJson(result));

      return _exchangeCode;
    }

    return null;
  }

  Future<ExchangeCodeModel?> unbind(DeviceModel? device) async {
    ExchangeCodeModel? code = await getExchangeCode();

    if (code == null) {
      return null;
    }

    device ??= DeviceModel(_device['deviceId'], _device['deviceType']);

    await _api!.codeUnBind(code.code, device);

    return syncBindExchangeCode();
  }

  Future<void> changeLocation(CityModel? cityModel) async {
    _city = cityModel;
  }

  Future<List<CityModel>?> getAllCities() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    var stringList = _prefs.getStringList(_citiesKey);

    if (stringList == null || stringList.isEmpty) {
      await _refreshCities(_api!);
    }

    for (var element in stringList!) {
      debugPrint('city str $element');
    }

    return stringList.map((e) => CityModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _refreshCities(Api api) async {
    var baseResponse = await api.citiesFindAll();

    if (Api.isSuc(baseResponse['code'])) {
      var result = baseResponse['result'] as List;

      List<CityModel> cities =
          result.map((e) => CityModel.fromJson(e)).toList();

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setStringList(_citiesKey,
          cities.map((e) => jsonEncode(e.toJson()).toString()).toList());
    }
  }

  Future<void> _refreshApiServers(Api api) async {
    try {
      var baseResponse = await api.apiServerFindAll();

      if (Api.isSuc(baseResponse['code'])) {
        var result = baseResponse['result'] as List;

        List<ApiServerModel> apiServers =
            result.map((e) => ApiServerModel.fromJson(e)).toList();

        SharedPreferences _prefs = await SharedPreferences.getInstance();

        _prefs.setStringList(
            _apiServersKey,
            apiServers
                .map((e) => e.toJson())
                .toList()
                .map((e) => jsonEncode(e))
                .toList());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Api?> _getAvailableApi() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    var baseUrl = _prefs.getString(_baseUrlKey);

    Api api = Api();

    api.configure(baseUrl ?? defaultApiBaseUrl);

    //Test ping
    try {
      var pong = await api.ping();

      if (Api.isSuc(pong['code'])) {
        debugPrint('ping suc !');
      }

      return api;
    } catch (e) {
      debugPrint(e.toString());
    }

    var stringList = _prefs.getStringList(_apiServersKey);

    if (stringList == null) {
      return null;
    }

    List<ApiServerModel> list =
        stringList.map((e) => ApiServerModel.fromJson(jsonDecode(e))).toList();

    for (var apiServer in list) {
      Api api = Api();
      api.configure(apiServer.prefix, 3000, 3000);

      //Test ping
      try {
        var pong = await api.ping();

        if (Api.isSuc(pong['code'])) {
          debugPrint('ping suc !');
        }

        _prefs.setString(_baseUrlKey, apiServer.prefix);

        _refreshApiServers(api);

        return api;
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return null;
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
    int cityId = 0;
    if (_city != null) {
      cityId = _city!.id;
    }
    var response = await _api!.nodeFind(cityId: cityId, protocol: protocol);

    if (Api.isSuc(response['code'])) {
      return NodeModel.fromJson(response['result']);
    }

    return null;
  }
}
