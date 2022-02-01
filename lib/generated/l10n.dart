// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get title {
    return Intl.message(
      'Home',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Not connected`
  String get not_connected {
    return Intl.message(
      'Not connected',
      name: 'not_connected',
      desc: '',
      args: [],
    );
  }

  /// `Connecting ...`
  String get connecting {
    return Intl.message(
      'Connecting ...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Authenticating ...`
  String get authenticating {
    return Intl.message(
      'Authenticating ...',
      name: 'authenticating',
      desc: '',
      args: [],
    );
  }

  /// `Configuring ...`
  String get configuring {
    return Intl.message(
      'Configuring ...',
      name: 'configuring',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get online {
    return Intl.message(
      'Connected',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Disconnecting ...`
  String get disconnecting {
    return Intl.message(
      'Disconnecting ...',
      name: 'disconnecting',
      desc: '',
      args: [],
    );
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Connection Mode`
  String get connection_mode {
    return Intl.message(
      'Connection Mode',
      name: 'connection_mode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Automatically select the appropriate protocol`
  String get auto_description {
    return Intl.message(
      'Automatically select the appropriate protocol',
      name: 'auto_description',
      desc: '',
      args: [],
    );
  }

  /// `Lightway Udp`
  String get lightway_udp {
    return Intl.message(
      'Lightway Udp',
      name: 'lightway_udp',
      desc: '',
      args: [],
    );
  }

  /// `Lightway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission`
  String get lightway_udp_description {
    return Intl.message(
      'Lightway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission',
      name: 'lightway_udp_description',
      desc: '',
      args: [],
    );
  }

  /// `Lightway Tcp`
  String get lightway_tcp {
    return Intl.message(
      'Lightway Tcp',
      name: 'lightway_tcp',
      desc: '',
      args: [],
    );
  }

  /// `Lightway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission`
  String get lightway_tcp_description {
    return Intl.message(
      'Lightway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission',
      name: 'lightway_tcp_description',
      desc: '',
      args: [],
    );
  }

  /// `Fastway Udp`
  String get fastway_dtls {
    return Intl.message(
      'Fastway Udp',
      name: 'fastway_dtls',
      desc: '',
      args: [],
    );
  }

  /// `Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission`
  String get fastway_dtls_description {
    return Intl.message(
      'Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission',
      name: 'fastway_dtls_description',
      desc: '',
      args: [],
    );
  }

  /// `Fastway Tcp`
  String get fastway_tls {
    return Intl.message(
      'Fastway Tcp',
      name: 'fastway_tls',
      desc: '',
      args: [],
    );
  }

  /// `Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission`
  String get fastway_tls_description {
    return Intl.message(
      'Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission',
      name: 'fastway_tls_description',
      desc: '',
      args: [],
    );
  }

  /// `Fastway Udp(Test)`
  String get fastway_udp {
    return Intl.message(
      'Fastway Udp(Test)',
      name: 'fastway_udp',
      desc: '',
      args: [],
    );
  }

  /// `Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission`
  String get fastway_udp_description {
    return Intl.message(
      'Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on UDP transmission',
      name: 'fastway_udp_description',
      desc: '',
      args: [],
    );
  }

  /// `Fastway Tcp(Test)`
  String get fastway_tcp {
    return Intl.message(
      'Fastway Tcp(Test)',
      name: 'fastway_tcp',
      desc: '',
      args: [],
    );
  }

  /// `Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission`
  String get fastway_tcp_description {
    return Intl.message(
      'Fastway is pioneering new VPN protocol, built for an always-on world. It makes your VPN experience speedier, more secure, and more reliable than ever，Based on TCP transmission',
      name: 'fastway_tcp_description',
      desc: '',
      args: [],
    );
  }

  /// `IKEv2(IPSec)`
  String get ikev2_ipsec {
    return Intl.message(
      'IKEv2(IPSec)',
      name: 'ikev2_ipsec',
      desc: '',
      args: [],
    );
  }

  /// `Auto-reconnect\Strong encryption\Stability and Speed VPN protocol`
  String get ikev2_ipsec_description {
    return Intl.message(
      'Auto-reconnect\\Strong encryption\\Stability and Speed VPN protocol',
      name: 'ikev2_ipsec_description',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `中文(简体)`
  String get chinese {
    return Intl.message(
      '中文(简体)',
      name: 'chinese',
      desc: '',
      args: [],
    );
  }

  /// `Secure stable fast vpn https://share.ftvpn.com`
  String get share_text {
    return Intl.message(
      'Secure stable fast vpn https://share.ftvpn.com',
      name: 'share_text',
      desc: '',
      args: [],
    );
  }

  /// `subject`
  String get share_subject {
    return Intl.message(
      'subject',
      name: 'share_subject',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Change Location`
  String get change_location {
    return Intl.message(
      'Change Location',
      name: 'change_location',
      desc: '',
      args: [],
    );
  }

  /// `Exchange Code`
  String get exchange_code {
    return Intl.message(
      'Exchange Code',
      name: 'exchange_code',
      desc: '',
      args: [],
    );
  }

  /// `Verifying...`
  String get verifying {
    return Intl.message(
      'Verifying...',
      name: 'verifying',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed!`
  String get verification_failed {
    return Intl.message(
      'Verification failed!',
      name: 'verification_failed',
      desc: '',
      args: [],
    );
  }

  /// `Verified successfully!`
  String get verified_successfully {
    return Intl.message(
      'Verified successfully!',
      name: 'verified_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Unbindding...`
  String get unbindding {
    return Intl.message(
      'Unbindding...',
      name: 'unbindding',
      desc: '',
      args: [],
    );
  }

  /// `Unbinding failed!`
  String get unbinding_failed {
    return Intl.message(
      'Unbinding failed!',
      name: 'unbinding_failed',
      desc: '',
      args: [],
    );
  }

  /// `Unbind successfully!`
  String get unbind_successfully {
    return Intl.message(
      'Unbind successfully!',
      name: 'unbind_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `remove`
  String get remove {
    return Intl.message(
      'remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get notice {
    return Intl.message(
      'Notice',
      name: 'notice',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to unbind ?`
  String get sure_to_unbind {
    return Intl.message(
      'Are you sure to unbind ?',
      name: 'sure_to_unbind',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Expires in(day)`
  String get expires_in_day {
    return Intl.message(
      'Expires in(day)',
      name: 'expires_in_day',
      desc: '',
      args: [],
    );
  }

  /// `Expired (day)`
  String get expired_day {
    return Intl.message(
      'Expired (day)',
      name: 'expired_day',
      desc: '',
      args: [],
    );
  }

  /// `Invalid exchange code!`
  String get invalid_exchange_code {
    return Intl.message(
      'Invalid exchange code!',
      name: 'invalid_exchange_code',
      desc: '',
      args: [],
    );
  }

  /// `Connection error!`
  String get connection_error {
    return Intl.message(
      'Connection error!',
      name: 'connection_error',
      desc: '',
      args: [],
    );
  }

  /// `Unknow error!`
  String get unknown_error {
    return Intl.message(
      'Unknow error!',
      name: 'unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get devices {
    return Intl.message(
      'Devices',
      name: 'devices',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Unable to access the Internet! Please check network settings.`
  String get unable_access_internet {
    return Intl.message(
      'Unable to access the Internet! Please check network settings.',
      name: 'unable_access_internet',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Retrying, please wait...`
  String get retrying_pls_wait {
    return Intl.message(
      'Retrying, please wait...',
      name: 'retrying_pls_wait',
      desc: '',
      args: [],
    );
  }

  /// `Retry failed! Please check network settings.`
  String get retry_failed {
    return Intl.message(
      'Retry failed! Please check network settings.',
      name: 'retry_failed',
      desc: '',
      args: [],
    );
  }

  /// `Success!`
  String get success {
    return Intl.message(
      'Success!',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Out of memory!`
  String get error_out_of_memory {
    return Intl.message(
      'Out of memory!',
      name: 'error_out_of_memory',
      desc: '',
      args: [],
    );
  }

  /// `Internal error!`
  String get error_internal {
    return Intl.message(
      'Internal error!',
      name: 'error_internal',
      desc: '',
      args: [],
    );
  }

  /// `Node Offline!`
  String get error_offline {
    return Intl.message(
      'Node Offline!',
      name: 'error_offline',
      desc: '',
      args: [],
    );
  }

  /// `TLS error!`
  String get error_tls {
    return Intl.message(
      'TLS error!',
      name: 'error_tls',
      desc: '',
      args: [],
    );
  }

  /// `NIC error!`
  String get error_tun {
    return Intl.message(
      'NIC error!',
      name: 'error_tun',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
