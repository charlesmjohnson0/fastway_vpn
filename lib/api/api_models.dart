import 'package:dio/dio.dart';
import 'package:fastway/common/global.dart';

class BaseResponse<T> {
  BaseResponse({required this.code, this.result, this.msg, this.error});
  int code;
  String? msg;
  T? result;
  DioError? error;

  bool get isSuc => code == 200;
}

class ApiServerModel {
  ApiServerModel(
      {required this.prefix,
      this.shareUrl,
      this.supportUrl,
      this.privacyPolicyUrl,
      this.termsOfServiceUrl});

  String prefix;
  String? shareUrl;
  String? supportUrl;
  String? privacyPolicyUrl;
  String? termsOfServiceUrl;

  factory ApiServerModel.fromJson(Map<String, dynamic> json) {
    return ApiServerModel(
        prefix: json['prefix'],
        shareUrl: json['shareUrl'],
        supportUrl: json['supportUrl'],
        privacyPolicyUrl: json['privacyPolicyUrl'],
        termsOfServiceUrl: json['termsOfServiceUrl']);
  }

  Map toJson() {
    Map map = {};
    map['prefix'] = prefix;
    map['shareUrl'] = shareUrl;
    map['supportUrl'] = supportUrl;
    map['privacyPolicyUrl'] = privacyPolicyUrl;
    map['termsOfServiceUrl'] = termsOfServiceUrl;

    return map;
  }
}

class CountryModel {
  CountryModel(
      {required this.fullName,
      required this.iso3,
      required this.iso2,
      required this.fullNameCN});

  String fullNameCN;
  String fullName;
  String iso2;
  String iso3;

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
        fullName: json['fullName'],
        iso3: json['iso3'],
        iso2: json['iso2'],
        fullNameCN: json['fullNameCN']);
  }

  Map toJson() {
    Map map = {};
    map['fullName'] = fullName;
    map['fullNameCN'] = fullNameCN;
    map['iso2'] = iso2;
    map['iso3'] = iso3;

    return map;
  }
}

class CityModel {
  CityModel({required this.id, required this.country, required this.name});

  int id;
  CountryModel country;
  String name;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
        id: json['id'],
        country: CountryModel.fromJson(json['country']),
        name: json['name']);
  }

  Map toJson() {
    Map map = {};
    map['id'] = id;
    map['country'] = country.toJson();
    map['name'] = name;

    return map;
  }
}

class NodeModel {
  NodeModel({
    required this.city,
    required this.name,
    required this.publicIP,
    this.domain,
    required this.crt,
    required this.fyUdpPort,
    required this.fyTcpPort,
    required this.fyDtlsPort,
    required this.fyTlsPort,
  });

  CityModel city;
  String name;
  String publicIP;
  String? domain;
  String crt;
  int fyUdpPort;
  int fyTcpPort;
  int fyDtlsPort;
  int fyTlsPort;

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      city: CityModel.fromJson(json['city']),
      crt: json['crt'],
      name: json['name'],
      publicIP: json['publicIP'],
      domain: json['domain'] == '' ? null : json['domain'],
      fyUdpPort: json['fyUdpPort'],
      fyTcpPort: json['fyTcpPort'],
      fyDtlsPort: json['fyDtlsPort'],
      fyTlsPort: json['fyTlsPort'],
    );
  }

  Map toMap() {
    Map map = {};
    map['city'] = city.toJson();
    map['name'] = name;
    map['publicIP'] = publicIP;
    map['domain'] = domain;
    map['crt'] = crt;
    map['lwUdpPort'] = fyUdpPort;
    map['lwTcpPort'] = fyTcpPort;
    return map;
  }
}

class DeviceModel {
  DeviceModel(this._deviceId, this._deviceType);
  final String _deviceId;
  final DeviceType _deviceType;

  String get deviceId => _deviceId;
  DeviceType get deviceType => _deviceType;

  factory DeviceModel.fromJson(Map<String, dynamic> data) {
    DeviceType? deviceType;

    for (var element in DeviceType.values) {
      if (element.index == data['platform']) {
        deviceType = element;
      }
    }

    if (deviceType == null) {
      if (data['platform'] == 'ANDROID') {
        deviceType = DeviceType.android;
      } else if (data['platform'] == 'ANDROID') {
        deviceType = DeviceType.android;
      } else if (data['platform'] == 'IOS') {
        deviceType = DeviceType.iOS;
      } else if (data['platform'] == 'WINDOW') {
        deviceType = DeviceType.windows;
      } else if (data['platform'] == 'MACOS') {
        deviceType = DeviceType.macOS;
      } else if (data['platform'] == 'LINUX') {
        deviceType = DeviceType.linux;
      } else {
        deviceType = DeviceType.error;
      }
    }

    return DeviceModel(data['deviceId'], deviceType);
  }

  Map toJson() {
    Map map = {};
    map['deviceId'] = deviceId;
    map['platform'] = deviceType.index;
    return map;
  }
}

class ExchangeCodeModel {
  ExchangeCodeModel(
      {required this.code,
      required this.validStartTime,
      required this.validEndTime,
      required this.devices});

  String code;
  String validStartTime;
  String validEndTime;
  List<DeviceModel> devices;

  DateTime get startTime {
    return DateTime.parse(validStartTime);
  }

  DateTime get endTime {
    return DateTime.parse(validEndTime);
  }

  bool get valid {
    return expiresInDays >= 0;
  }

  int get expiresInDays {
    var difference = endTime.difference(DateTime.now());

    return difference.inDays;
  }

  factory ExchangeCodeModel.fromJson(Map<String, dynamic> data) {
    List deviceList = data['devices'] as List;

    return ExchangeCodeModel(
      code: data['code'],
      validStartTime: data['validStartTime'],
      validEndTime: data['validEndTime'],
      devices: deviceList.map((e) {
        return DeviceModel.fromJson(e);
      }).toList(),
    );
  }

  Map toJson() {
    Map map = {};
    map['code'] = code;
    map['validStartTime'] = validStartTime;
    map['validEndTime'] = validEndTime;
    map['devices'] = devices;
    return map;
  }
}
