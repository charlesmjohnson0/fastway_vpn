import 'dart:async';

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
  final FyVpnSdk _sdk = FyVpnSdk();

  final Global global = Global();

  fy_state _state = fy_state.NONE;

  Future<fy_state> getState() async {
    _state = await _sdk.state;
    return _state;
  }

  Stream<fy_state> get onStateChanged => _sdk.onStateChanged;

  Stream<fy_error> get onError => _sdk.onError;

  int get errorCode => _sdk.errorCode;

  VpnProtocol get protocol => global.protocol;

  void changeProtocol(VpnProtocol protocol) {
    global.changeProtocol(protocol).then((value) => notifyListeners());
  }

  void changeLocation(CityModel city) {
    global.changeLocation(city).then((value) => notifyListeners());
  }

  Future<fy_state> toggle() async {
    return getState().then((state) {
      _state = state;
      switch (_state) {
        case fy_state.AUTHENTICATING:
        case fy_state.CONFIGURING:
        case fy_state.CONNECTING:
        case fy_state.ONLINE:
          return disconnect();
        default:
          return connect();
      }
    });
  }

  Future<fy_state> connect() async {
    bool prepared = await _sdk.prepare();

    if (!prepared) {
      return getState();
    }

    prepared = await _sdk.prepared();

    if (!prepared) {
      return getState();
    }

    // var stateBak = getState();

    _state = fy_state.CONNECTING;

    global.findNode().then((node) {
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

        // debugPrint('Protocol  : $protocolStr');
        // debugPrint('IP        : ${node.domain ?? node.publicIP}');
        // debugPrint('PORT      : $port');
        // debugPrint('username  : $username');
        // debugPrint('password  : $password');

        _sdk.startVpnService(protocolStr, node.domain ?? node.publicIP, port,
            username, password!, node.crt);
      } else {
        _state = fy_state.NONE;
        notifyListeners();
      }
    });

    return _state;
  }

  Future<fy_state> disconnect() async {
    await _sdk.stop();

    return getState();
  }
}
