import 'package:fy_vpn_sdk/fy_vpn_sdk.dart';

import '/api/api_models.dart';
import '/common/global.dart';
import 'package:flutter/material.dart';

enum VpnProtocol {
  auto,
  udp,
  tcp,
  dtls,
  tls,
}

class VpnModel extends ChangeNotifier {
  final Global global = Global();

  fy_state _state = fy_state.NONE;

  fy_state get state => _state;

  VpnModel() {
    FyVpnSdk.onStateChanged.listen((event) {
      _state = event;
      notifyListeners();
    });
  }

  VpnProtocol get protocol => global.protocol;

  void changeProtocol(VpnProtocol protocol) {
    global.changeProtocol(protocol).then((value) => notifyListeners());
  }

  void changeLocation(CityModel city) {
    global.changeLocation(city).then((value) => notifyListeners());
  }

  Future<void> toggle() async {
    _state = await FyVpnSdk.state;

    switch (_state) {
      case fy_state.AUTHENTICATING:
      case fy_state.CONFIGURING:
      case fy_state.CONNECTING:
      case fy_state.ONLINE:
        await disconnect();
        break;
      default:
        await connect();
    }

    _state = await FyVpnSdk.state;

    notifyListeners();
  }

  Future<void> connect() async {
    bool prepared = await FyVpnSdk.prepare();

    if (!prepared) {
      return;
    }

    prepared = await FyVpnSdk.prepared();

    if (!prepared) {
      return;
    }

    NodeModel? node = await global.findNode();

    if (node != null) {
      String protocolStr;
      int port;
      String username = global.userName;
      String? password = global.password;

      switch (global.protocol) {
        case VpnProtocol.udp:
          protocolStr = 'UDP';
          port = node.fyUdpPort;
          break;

        case VpnProtocol.tcp:
          protocolStr = 'TCP';
          port = node.fyTcpPort;
          break;
        case VpnProtocol.tls:
          protocolStr = 'TLS';
          port = node.fyTlsPort;
          break;
        case VpnProtocol.auto:
        case VpnProtocol.dtls:
        default:
          protocolStr = 'DTLS';
          port = node.fyDtlsPort;
          break;
      }

      FyVpnSdk.startVpnService(protocolStr, node.domain ?? node.publicIP, port,
          username, password!, node.cert.crt);
    }
  }

  Future<void> disconnect() async {
    FyVpnSdk.stop();
  }
}
