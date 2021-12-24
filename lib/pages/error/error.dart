import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vpn/common/global.dart';
import 'package:vpn/generated/l10n.dart';
import 'package:vpn/pages/home/home.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  ErrorPageState createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {
  Global global = Global();
  bool inputUrl = false;

  void apiCheck() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).retrying_pls_wait),
    ));

    if (inputUrl && _urlController.text.isNotEmpty) {
      global.setBaseUrl(_urlController.text);
    }

    global.initApi().then((value) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (value == 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).success),
          duration: const Duration(seconds: 3),
        ));
        Timer(
            const Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (builder) => const HomePage())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).retry_failed),
          duration: const Duration(seconds: 3),
        ));
      }
    });
  }

  final TextEditingController _urlController = TextEditingController();

  Widget inputUrlField() {
    return TextField(
      maxLines: 1,
      keyboardType: TextInputType.url,
      onSubmitted: (val) {},
      onChanged: (val) {},
      controller: _urlController,
      decoration: const InputDecoration(
        // prefixIcon: Icon(Icons.network_cell_rounded),
        hintText: 'http://',
        border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
        // counter: Text('${_codeController.text.replaceAll("-", "").length}/16'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              inputUrl == false
                  ? Text(
                      S.of(context).unable_access_internet,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : inputUrlField(),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () => apiCheck(),
                  onLongPress: () {
                    setState(() {
                      inputUrl = !inputUrl;
                    });
                  },
                  child: Text(
                    S.of(context).retry,
                    // style: TextStyle(fontSize: 18),
                  )),
            ],
          ),
        ));
  }
}
