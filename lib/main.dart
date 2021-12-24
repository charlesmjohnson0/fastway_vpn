import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vpn/pages/splash/splash.dart';
import '/common/global.dart';
import '/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/generated/l10n.dart';
import 'package:provider/provider.dart';

import 'models/app_model.dart';
import 'models/vpn_model.dart';

const String defaultApiUrl = 'http://api.fastway.cloud';
const int versionMajor = 2;
const int versionMinor = 1;
const int versionDevNo = 3344;
const String copyrightInfo = 'Copyright Fastway Inc. 2016-2022';

void main() async {
  var app = Global();

  FlutterError.onError = (FlutterErrorDetails details) {
    app.reportError(details.exception, details.stack);
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      var appModel = AppModel();
      var vpnModel = VpnModel();

      app
          .init(
              baseApiUrl: defaultApiUrl,
              copyrightInfo: copyrightInfo,
              versionInfo: 'Version $versionMajor.$versionMinor.$versionDevNo')
          .then((e) => runApp(MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => appModel),
                  ChangeNotifierProvider(create: (context) => vpnModel),
                ],
                child: const FastwayApp(),
              )));
    },
    (Object error, StackTrace stack) {
      app.reportError(error, stack);
    },
  );
}

class FastwayApp extends StatelessWidget {
  const FastwayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('App start...');
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        return MaterialApp(
          title: '',
          theme: AppTheme.darkTheme(),
          darkTheme: AppTheme.darkTheme(),
          locale: appModel.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
            var result = supportedLocales.where(
                (element) => element.languageCode == locale!.languageCode);
            if (result.isNotEmpty) {
              return locale;
            }
            return const Locale('en');
          },
          // home: const HomePage(),
          home: const SplashPage(),
        );
      },
    );
  }
}
