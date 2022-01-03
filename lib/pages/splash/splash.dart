import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vpn/common/global.dart';
import 'package:vpn/pages/error/error.dart';
import 'package:vpn/pages/home/home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  Global global = Global();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();

    global.initApi().then((value) {
      StatefulWidget page;
      if (value == 0) {
        page = const HomePage();
      } else {
        page = const ErrorPage();
      }

      Timer(
          const Duration(seconds: 1),
          () => Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (builder) => page)));
    });
  }

  @override
  void deactivate() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Image(
            image: AssetImage('images/logo-transparent.png'),
            fit: BoxFit.scaleDown),
      ),
    );
  }
}
