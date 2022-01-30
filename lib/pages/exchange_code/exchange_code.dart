import 'package:flutter/material.dart';
import 'package:fastway/api/api_models.dart';
import 'package:fastway/common/global.dart';
import '/generated/l10n.dart';
import 'package:flutter/services.dart';

class ExchangeCodePage extends StatefulWidget {
  const ExchangeCodePage({Key? key}) : super(key: key);

  @override
  State<ExchangeCodePage> createState() => ExchangeCodePageState();
}

class ExchangeCodePageState extends State<ExchangeCodePage> {
  Global global = Global();
  ExchangeCodeModel? exchangeCode;

  @override
  void initState() {
    super.initState();

    global.getExchangeCode().then((value) {
      setState(() {
        exchangeCode = value;
      });
    });

    global.syncBindExchangeCode().then((value) {
      setState(() {
        exchangeCode = value;
      });
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void bind(String code) {
    if (_isValidCode(code)) {
      //close keyboard
      _focusNode.unfocus();

      code = code.replaceAll('-', '').replaceAll(' ', '');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).verifying),
      ));
      global.bind(code).then((baseResponse) async {
        await Future.delayed(const Duration(seconds: 2));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (baseResponse.isSuc) {
          exchangeCode = baseResponse.result;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).verified_successfully),
            duration: const Duration(seconds: 2),
          ));
          // Future.delayed(const Duration(seconds: 3), () {
          //   Navigator.of(context).pop();
          // });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).verification_failed),
            duration: const Duration(seconds: 2),
          ));
        }
      });
    }
  }

  void unbind(DeviceModel? device) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).unbindding),
    ));
    global.unbind(device).then((baseResponse) {
      if (baseResponse != null && baseResponse.isSuc) {
        global.syncBindExchangeCode().then((value) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).unbind_successfully),
            duration: const Duration(seconds: 2),
          ));

          setState(() {
            exchangeCode = value;
          });
        });
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).unbinding_failed),
          duration: const Duration(seconds: 2),
        ));
      }
    });
  }

  bool _isValidCode(String? code) {
    if (code == null) {
      return false;
    }
    return code.replaceAll('-', '').replaceAll(' ', '').length == 16;
  }

  String formatCode(String code) {
    return code.stringSeparate(
        separator: '-', count: 4, fromRightToLeft: false);
  }

  bool _validCode = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _codeController = TextEditingController();

  Widget buildUnBind(BuildContext context) {
    if (_codeController.text.isEmpty) {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value != null && _isValidCode(value.text)) {
          setState(() {
            _codeController.text = value.text!;
            _validCode = true;
          });
        }
      });
    }

    return TextField(
      maxLines: 1,
      maxLength: 19,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      focusNode: _focusNode,
      // inputFormatters: [
      //   TextInputFormatter.withFunction((oldValue, newValue) =>
      //       TextEditingValue(
      //           text: newValue.text.stringSeparate(
      //               separator: '-', count: 4, fromRightToLeft: false)))
      // ],
      onSubmitted: (val) {
        _validCode = _isValidCode(val);
      },
      onChanged: (val) {
        _validCode = _isValidCode(val);
        setState(() {});
        // _codeController.selection = TextSelection.fromPosition(
        //     TextPosition(offset: val.length, affinity: TextAffinity.upstream));
      },
      controller: _codeController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.credit_card),
        suffixIcon: _validCode
            ? TextButton(
                onPressed: () {
                  String code = _codeController.text;
                  bind(code);
                },
                child: Text(S.of(context).submit),
              )
            : null,
        hintText: 'XXXX-XXXX-XXXX-XXXX',
        border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
        // counter: Text('${_codeController.text.replaceAll("-", "").length}/16'),
      ),
    );
  }

  Future<int?> _showDevices(BuildContext context) async {
    return showModalBottomSheet<int>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          height: MediaQuery.of(context).size.height / 2.0,
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  Center(
                    child: Text(
                      S.of(context).devices,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      title: Text(exchangeCode!.devices[index].deviceId,
                          overflow: TextOverflow.visible
                          // maxLines: 1,
                          ),
                      trailing: TextButton(
                        child: Text(S.of(context).remove),
                        onPressed: () {
                          Navigator.of(context).pop(index);
                          unbind(exchangeCode!.devices[index]);
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).pop(index);
                      });
                },
                itemCount: exchangeCode!.devices.length,
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget buildBinded(BuildContext context) {
    return Card(
      color: Colors.blue,
      child: AspectRatio(
        aspectRatio: 2 / 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              height: 24,
              alignment: const Alignment(1, 0),
              child: IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(S.of(context).notice),
                          content: Text(S.of(context).sure_to_unbind),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(S.of(context).no)),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  unbind(null);
                                },
                                child: Text(S.of(context).yes)),
                          ],
                        );
                      });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatCode(exchangeCode!.code),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(
                  width: 5,
                ),
                TextButton(
                    // style: ButtonStyle(
                    //     shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20))),
                    //     side: MaterialStateProperty.all(
                    //         const BorderSide(color: Colors.white, width: 1))),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: exchangeCode!.code));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.of(context).copied),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    child: Text(S.of(context).copy,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      exchangeCode!.expiresInDays > 0
                          ? S.of(context).expires_in_day
                          : S.of(context).expired_day,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('${exchangeCode!.expiresInDays.abs()}',
                        style: TextStyle(
                            color: exchangeCode!.expiresInDays > 0
                                ? Colors.white
                                : Colors.yellow,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                InkWell(
                  onTap: () {
                    _showDevices(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        S.of(context).devices,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('${exchangeCode!.devices.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).exchange_code),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: exchangeCode == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                exchangeCode == null
                    ? buildUnBind(context)
                    : buildBinded(context)
              ],
            ),
          ),
        ),
        onWillPop: () async {
          _focusNode.unfocus();
          return true;
        });
  }
}

extension StringSeprate on String {
  String stringSeparate(
      {int count = 3, String separator = ",", bool fromRightToLeft = true}) {
    if (isEmpty) {
      return "";
    }

    if (count < 1) {
      return this;
    }

    if (count >= length) {
      return this;
    }

    var str = replaceAll(separator, "");

    var chars = str.runes.toList();
    var namOfSeparation =
        (chars.length.toDouble() / count.toDouble()).ceil() - 1;
    var separatedChars =
        List.filled(chars.length + namOfSeparation.round(), ' ');
    var j = 0;
    for (var i = 0; i < chars.length; i++) {
      separatedChars[j] = String.fromCharCode(chars[i]);
      if (i > 0 && (i + 1) < chars.length && (i + 1) % count == 0) {
        j += 1;
        separatedChars[j] = separator;
      }

      j += 1;
    }

    return fromRightToLeft
        ? String.fromCharCodes(separatedChars.join().runes.toList().reversed)
        : separatedChars.join();
  }
}
