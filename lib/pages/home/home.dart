import 'dart:async';

import 'package:provider/provider.dart';
import 'package:vpn/api/api_models.dart';
import 'package:vpn/models/vpn_model.dart';
import 'package:vpn/pages/exchange_code/exchange_code.dart';

import '/common/global.dart';
import 'package:flutter/material.dart';
import '/generated/l10n.dart';
import '/pages/settings/settings.dart';
import 'package:flag/flag.dart';
import 'package:fy_vpn_sdk/fy_vpn_sdk.dart';

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
          fullName: 'Smart', iso2: 'fy', iso3: 'fy', fullNameCN: 'Smart');
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
          default:
            message = S.of(context).unknown_error;
            break;
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ));
      });

      vpnModel.getState().then((value) => _state = value);
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
      title: Text(country.fullName),
      leading: Flag.fromString(
        country.iso2,
        height: 18,
        width: 36,
      ),
      selected: global.city != null
          ? country.iso2 == global.city!.country.iso2
          : false,
      onTap: () {
        //first city
        global.changeLocation(cities[0]);
        Navigator.of(context).pop();
      },
    );
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
              height: MediaQuery.of(context).size.height / 2.0,
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

                            return ListTile(
                              title: Text(country.fullName),
                              leading: Flag.fromString(
                                country.iso2,
                                height: 18,
                                width: 36,
                              ),
                              selected: global.city != null
                                  ? country.iso2 == global.city!.country.iso2
                                  : false,
                              onTap: () {
                                //first city
                                if (cities[0].id == 0) {
                                  global.changeLocation(null);
                                } else {
                                  global.changeLocation(cities[0]);
                                }

                                setState(() {});
                                Navigator.of(context).pop(index);
                              },
                            );
                          }))
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
                        vpnModel.toggle();
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
            Builder(
              builder: (context) => HomeLocation(
                onTap: () {
                  showLocationList();
                },
              ),
            )
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
        margin: const EdgeInsets.all(60),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColorLight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 36,
                    height: 18,
                    child: Flag.fromString(
                      global.city == null ? 'logo' : global.city!.country.iso2,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  global.city == null ? 'SMART' : global.city!.country.fullName,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Icon(
              Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
