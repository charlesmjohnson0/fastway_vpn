import '/api/api_models.dart';

import '/common/global.dart';
import 'package:flutter/material.dart';
import '/generated/l10n.dart';
// import '/pages/settings/settings_connection_mode.dart';
import '/pages/settings/settings_language.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class Option {
  Option(this.name, this.onTap);

  String name;
  GestureTapCallback onTap;
}

class _SettingsState extends State<SettingsPage> {
  Global global = Global();
  String text = '';
  String subject = '';
  List<String> imagePaths = [];

  List<Option> options = List.empty(growable: true);

  // void _onShare(BuildContext context) async {
  //   text = S.of(context).share_text;
  //   subject = S.of(context).share_subject;

  //   final box = context.findRenderObject() as RenderBox?;

  //   if (imagePaths.isNotEmpty) {
  //     await Share.shareFiles(imagePaths,
  //         text: text,
  //         subject: subject,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   } else {
  //     await Share.share(text,
  //         subject: subject,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   }
  // }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        // headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void loadOptions() {
    options.clear();

    // //connection mode
    // options.add(Option(S.of(context).connection_mode, () {
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => const ConnectionModePage()));
    // }));

    //language
    options.add(Option(S.of(context).language, () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LanguagePage()));
    }));

    ApiServerModel? apiServerModel = global.apiServerModel;

    if (apiServerModel != null) {
      // if (apiServerModel.shareUrl != null) {
      //     //TODO share
      //     options.add(Option(S.of(context).share, () {
      //       _onShare(context);
      //     }));
      // }

      if (apiServerModel.supportUrl != null) {
        //support
        options.add(Option(S.of(context).support, () {
          _launchInBrowser(apiServerModel.supportUrl!);
        }));
      }

      if (apiServerModel.privacyPolicyUrl != null) {
        //privacy policy
        options.add(Option(S.of(context).privacy_policy, () {
          _launchInBrowser(apiServerModel.privacyPolicyUrl!);
        }));
      }

      if (apiServerModel.termsOfServiceUrl != null) {
        //terms of service
        options.add(Option(S.of(context).terms_of_service, () {
          _launchInBrowser(apiServerModel.termsOfServiceUrl!);
        }));
      }
    }
    // //about
    // options.add(Option(S.of(context).about, () {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => const AboutPage()));
    // }));
  }

  @override
  Widget build(BuildContext context) {
    loadOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(
              height: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: options.length,
                    itemBuilder: (ctx, index) {
                      final option = options[index];
                      return ListTile(
                        title: Text(option.name),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: option.onTap,
                      );
                    })),
            Text(global.versionInfo),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.copyright,
                  size: 16,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(global.copyrightInfo),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
