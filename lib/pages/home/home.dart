import 'dart:async';

import 'package:provider/provider.dart';
import 'package:fastway/api/api_models.dart';
import 'package:fastway/models/vpn_model.dart';
import 'package:fastway/pages/exchange_code/exchange_code.dart';

import '/common/global.dart';
import 'package:flutter/material.dart';
import '/generated/l10n.dart';
import '/pages/settings/settings.dart';
import 'package:fy_vpn_sdk/fy_vpn_sdk.dart';

AssetImage buildCountryIcon(CountryModel? country) {
  if (country == null || country.iso2.toLowerCase() == 'smart') {
    return const AssetImage('images/smart.png');
  }

  return AssetImage('icons/flags/png/${country.iso2.toLowerCase()}.png',
      package: 'country_icons');
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Global global = Global();
  final Map<CountryModel, List<CityModel>> _countryMap = {};

  @override
  void initState() {
    super.initState();
    global.isExchangeCodeValid.then((value) {
      if (value == false) {
        //to bind exchange code
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ExchangeCodePage()));
      } else {
        //sync state

      }
    });
    global.getAllCities().then((cities) {
      _countryMap.clear();

      //add smart choice
      CountryModel smartCountry = CountryModel(
          fullName: 'Smart', iso2: 'Smart', iso3: 'Smart', fullNameCN: 'Smart');
      CityModel smartCity =
          CityModel(id: 0, country: smartCountry, name: 'Smart');

      _countryMap.putIfAbsent(smartCountry, () => [smartCity]);

      if (cities != null) {
        _countryMap.addAll(cities.fold(<CountryModel, List<CityModel>>{},
            (Map<CountryModel, List<CityModel>> a, b) {
          CountryModel? countryKey;

          a.forEach((key, value) {
            if (key.iso2 == b.country.iso2) {
              countryKey = key;
              value.add(b);
            }
          });

          if (countryKey == null) {
            a.putIfAbsent(b.country, () => []).add(b);
          }

          return a;
        }));
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      VpnModel vpnModel = Provider.of<VpnModel>(context, listen: false);

      debugPrint('state subscription!');
      _stateSubscription = vpnModel.onStateChanged.listen((event) {
        setState(() {
          debugPrint('state change : $event');
          _state = event;
        });
      });

      debugPrint('error subscription!');
      _errorSubscription = vpnModel.onError.listen((event) {
        String message;
        debugPrint('error : $event');
        switch (event) {
          case fy_error.fy_err_auth_deny:
            message = S.of(context).invalid_exchange_code;
            break;
          case fy_error.fy_err_connection:
            message = S.of(context).connection_error;
            break;
          case fy_error.fy_err_internel:
            message = S.of(context).error_internal;
            break;
          case fy_error.fy_err_offline:
            message = S.of(context).error_offline;
            break;
          case fy_error.fy_err_out_of_memory:
            message = S.of(context).error_out_of_memory;
            break;
          case fy_error.fy_err_tls:
            message = S.of(context).error_tls;
            break;
          case fy_error.fy_err_tun:
            message = S.of(context).error_tun;
            break;
          default:
            message = S.of(context).unknown_error + " (${vpnModel.errorCode})";
            break;
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ));

        global.reportError('runtime error code : $event',
            StackTrace.fromString('error : ${vpnModel.errorCode}'));

        //restart
        vpnModel.toggle();
      });

      vpnModel.getState().then((value) => setState(() {
            _state = value;
          }));
    });
  }

  fy_state? _state;
  StreamSubscription<fy_error>? _errorSubscription;
  StreamSubscription<fy_state>? _stateSubscription;

  @override
  void deactivate() {
    super.deactivate();
    _errorSubscription!.cancel();
    _stateSubscription!.cancel();
  }

  Widget getStateIcon() {
    Color? color;
    switch (_state) {
      case fy_state.AUTHENTICATING:
      case fy_state.CONFIGURING:
      case fy_state.CONNECTING:
        color = Colors.yellow;
        break;
      case fy_state.ONLINE:
        color = Colors.green;
        break;
      case fy_state.DISCONNECTING:
        color = Colors.yellow;
        break;
      case fy_state.DISCONNECTED:
        color = null;
        break;
      case fy_state.ERROR:
        color = Colors.red;
        break;
      default:
    }
    return Icon(Icons.power_settings_new, color: color);
  }

  Widget getStateText() {
    String text = '';

    switch (_state) {
      case fy_state.AUTHENTICATING:
        text = S.of(context).authenticating;
        break;
      case fy_state.CONFIGURING:
        text = S.of(context).configuring;
        break;
      case fy_state.CONNECTING:
        text = S.of(context).connecting;
        break;
      case fy_state.ONLINE:
        text = S.of(context).online;
        break;
      case fy_state.DISCONNECTED:
        text = S.of(context).disconnected;
        break;
      case fy_state.DISCONNECTING:
        text = S.of(context).disconnecting;
        break;
      case fy_state.ERROR:
        text = S.of(context).error;
        break;
      default:
    }

    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget buildListItem(CountryModel country, List<CityModel> cities) {
    return ListTile(
      title: Text(country.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: Image(
        image: buildCountryIcon(country),
        fit: BoxFit.scaleDown,
        height: 18,
        width: 36,
      ),
      selected:
          global.city != null && country.iso2 == global.city!.country.iso2,
      onTap: () {
        //first city
        global.changeLocation(cities[0]);
        Navigator.of(context).pop();
      },
    );
  }

  Widget countryItem(CountryModel country, List<CityModel> cities) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image(
                  alignment: Alignment.center,
                  width: 36,
                  height: 18,
                  image: buildCountryIcon(country),
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  width: 10,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    country.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            ((global.city == null && country.iso2.toLowerCase() == 'smart') ||
                    (global.city != null &&
                        country.iso2 == global.city!.country.iso2))
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const SizedBox(),
          ],
        ),
      ),
      onTap: () {
        if (cities[0].id == 0) {
          global.changeLocation(null);
        } else {
          global.changeLocation(cities[0]);
        }

        setState(() {});
        Navigator.of(context).pop();
      },
    );

    // return ListTile(
    //   title: Text(
    //     country.fullName,
    //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //   ),
    //   leading: Image(
    //     image: buildCountryIcon(country),
    //     fit: BoxFit.scaleDown,
    //     height: 18,
    //     width: 36,
    //   ),
    //   selected: (global.city == null &&
    //           country.iso2.toLowerCase() == 'smart') ||
    //       (global.city != null && country.iso2 == global.city!.country.iso2),
    //   onTap: () {
    //     //first city
    //     if (cities[0].id == 0) {
    //       global.changeLocation(null);
    //     } else {
    //       global.changeLocation(cities[0]);
    //     }

    //     setState(() {});
    //     Navigator.of(context).pop();
    //   },
    // );
  }

  void showLocationList() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        builder: (context) {
          return Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              height: MediaQuery.of(context).size.height / 1.6,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Stack(
                      textDirection: TextDirection.rtl,
                      children: [
                        Center(
                          child: Text(
                            S.of(context).change_location,
                            style: const TextStyle(fontSize: 16.0),
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
                    height: 0.5,
                  ),
                  Expanded(
                      child: ListView.separated(
                          separatorBuilder: (context, index) => const Divider(),
                          padding: EdgeInsets.zero,
                          itemCount: _countryMap.length,
                          itemBuilder: (BuildContext context, int index) {
                            var country = _countryMap.keys.toList()[index];
                            List<CityModel> cities =
                                _countryMap.values.toList()[index];

                            return countryItem(country, cities);
                          })),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnModel>(builder: (context, vpnModel, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).title),
          actions: <Widget>[
            Builder(builder: (ctx) {
              return IconButton(
                icon: const Icon(
                  Icons.credit_card,
                ),
                onPressed: () {
                  // Scaffold.of(ctx).openEndDrawer();
                  Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (context) => const ExchangeCodePage()));
                },
              );
            }), //setting btn
            Builder(builder: (ctx) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  // Scaffold.of(ctx).openEndDrawer();
                  Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
              );
            }),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    global.isExchangeCodeValid.then((value) {
                      if (value) {
                        vpnModel.toggle().then((value) {
                          setState(() {
                            _state = value;
                          });
                        });
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExchangeCodePage()));
                      }
                    });
                  },
                  // icon: const Icon(Icons.power_settings_new, color: Colors.white),
                  icon: getStateIcon(),
                  iconSize: 128,
                ),
                const SizedBox(
                  height: 25,
                ),
                getStateText(),
              ],
            ),
            Builder(builder: (context) {
              return Container(
                margin: const EdgeInsets.fromLTRB(60, 0, 60, 60),
                height: 60,
                child: HomeLocation(
                  onTap: () {
                    showLocationList();
                  },
                ),
              );
            })
          ],
        ),
      );
    });
  }
}

class HomeLocation extends StatefulWidget {
  const HomeLocation({this.onTap, Key? key}) : super(key: key);

  final GestureTapCallback? onTap;

  @override
  _HomeLocationState createState() => _HomeLocationState();
}

class _HomeLocationState extends State<HomeLocation> {
  Global global = Global();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColorLight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            Image(
              alignment: Alignment.center,
              width: 36,
              height: 18,
              image: buildCountryIcon(
                  global.city != null ? global.city!.country : null),
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 180),
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  global.city == null ? 'Smart' : global.city!.country.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              // width: 36,
              height: 18,
              child: Icon(
                Icons.location_on_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
