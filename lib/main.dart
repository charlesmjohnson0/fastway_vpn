import 'dart:async';

import 'package:flutter/material.dart';
import '/common/global.dart';
import '/pages/home/home.dart';
import '/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/generated/l10n.dart';
import 'package:provider/provider.dart';

import 'models/app_model.dart';
import 'models/vpn_model.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    var app = Global();
    // Global.defaultApiBaseUrl = 'http://127.0.0.1:8080';

    var appModel = AppModel();
    var vpnModel = VpnModel();
    app.init().then((e) => runApp(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => appModel),
            ChangeNotifierProvider(create: (context) => vpnModel),
          ],
          child: const MyApp(),
        )));
  }, (error, st) => debugPrint(error.toString()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
          home: const HomePage(),
        );
      },
    );
  }
}
