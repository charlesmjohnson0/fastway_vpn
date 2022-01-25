import '/models/app_model.dart';
import 'package:flutter/material.dart';
import '/generated/l10n.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguageState createState() => _LanguageState();
}

class Language {
  Language(this.name, this.code);

  String name;
  String code;
}

class _LanguageState extends State<LanguagePage> {
  List<Language> languages = List.empty(growable: true);

  void loadLanguages() {
    languages.clear();
    languages.add(Language(S.of(context).english, "en"));
    languages.add(Language(S.of(context).chinese, "zh"));
  }

  @override
  Widget build(BuildContext context) {
    loadLanguages();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).language),
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
                itemCount: languages.length,
                itemBuilder: (ctx, index) {
                  final language = languages[index];
                  return ListTile(
                    title: Text(language.name),
                    trailing: null,
                    onTap: () => Provider.of<AppModel>(context, listen: false)
                        .changeLocale(language.code),
                    selected: Provider.of<AppModel>(context, listen: false)
                            .locale
                            .languageCode ==
                        language.code,
                  );
                }),
          )
        ],
      )),
    );
  }
}
