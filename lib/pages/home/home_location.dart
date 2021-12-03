import 'dart:math';

import '/api/api_models.dart';
import '/common/global.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '/generated/l10n.dart';

class HomeLocationListPage extends StatefulWidget {
  const HomeLocationListPage({Key? key}) : super(key: key);

  @override
  _HomeLocationListPageState createState() => _HomeLocationListPageState();
}

class _HomeLocationListPageState extends State<HomeLocationListPage> {
  Global global = Global();
  final Map<CountryModel, List<CityModel>> _countryMap = {};

  @override
  void initState() {
    super.initState();
    global.getAllCities().then((cities) {
      _countryMap.clear();

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

      // .values
      // .where((l) => l.isNotEmpty)
      // .map((l) => {
      //       'DateOfBirth': l.first['DateOfBirth'],
      //       'BirthDay': l.first['BirthDay'],
      //       'Data': l
      //           .map((e) => {
      //                 'Department': e['Department'],
      //                 'FullName': e['FullName'],
      //               })
      //           .toList()
      //     })
      // .toList();

      setState(() {});
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).change_location),
          leading: IconButton(
            icon: Transform.rotate(
              angle: 270 * (pi / 180),
              child: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
            child: Column(
          children: [
            const Divider(),
            Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    padding: EdgeInsets.zero,
                    itemCount: _countryMap.length,
                    itemBuilder: (BuildContext context, int index) {
                      var country = _countryMap.keys.toList()[index];
                      List<CityModel> cities =
                          _countryMap.values.toList()[index];

                      return buildListItem(country, cities);
                    }))
          ],
        )));
  }
}
