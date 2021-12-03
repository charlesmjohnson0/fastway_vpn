import 'package:flutter/material.dart';

class AppTheme {
  // MaterialColor _createMaterialColor(Color color) {
  //   List strengths = <double>[.05];
  //   Map swatch = <int, Color>{};
  //   final int r = color.red, g = color.green, b = color.blue;
  //
  //   for (int i = 1; i < 10; i++) {
  //     strengths.add(0.1 * i);
  //   }
  //   strengths.forEach((strength) {
  //     final double ds = 0.5 - strength;
  //     swatch[(strength * 1000).round()] = Color.fromRGBO(
  //       r + ((ds < 0 ? r : (255 - r)) * ds).round(),
  //       g + ((ds < 0 ? g : (255 - g)) * ds).round(),
  //       b + ((ds < 0 ? b : (255 - b)) * ds).round(),
  //       1,
  //     );
  //   });
  //   return MaterialColor(color.value, swatch);
  // }

  static ThemeData darkTheme() {
    return ThemeData(
      //应用程序的整体主题亮度
      brightness: Brightness.dark,
      //Material 主题中定义一种颜色，它具有十种颜色阴影的颜色样本。值越大颜色越深
      // primarySwatch: _createMaterialColor(Colors.white),
      //App主要部分的背景色（ToolBar,Tabbar等）
      primaryColor: Colors.black,
      //primaryColor的亮度
      primaryColorBrightness: Brightness.dark,
      //primaryColor的较浅版本
      primaryColorLight: const Color(0xFF202020),
      //primaryColor的较深版本
      primaryColorDark: Colors.black,
      // Color ? canvasColor,
      // shadowColor: Colors.black45,
      scaffoldBackgroundColor: Colors.black,
      // bottomAppBarColor: Colors.black,
      // cardColor: Colors.black,

      // focusColor: Colors.white,
      // hoverColor: Colors.white,
      // highlightColor: Colors.white,
      // splashColor: Colors.white,
      // selectedRowColor: Colors.grey,
      // unselectedWidgetColor: Colors.white,
      // disabledColor: Colors.grey,
      // buttonTheme: ButtonThemeData(),
      // toggleButtonsTheme: ToggleButtonsThemeData(),
      // secondaryHeaderColor: Colors.grey,
      backgroundColor: Colors.black,
      dialogBackgroundColor: const Color(0xFF202020),
      // indicatorColor: Colors.white,
      // hintColor: Colors.grey,
      // errorColor: Colors.amber,
      // toggleableActiveColor: Colors.white,
      // fontFamily: '',
      // textTheme: TextTheme(),
      // primaryTextTheme: TextTheme(),
      // inputDecorationTheme: InputDecorationTheme(),
      iconTheme: const IconThemeData(color: Color(0xFFA1A1A1)),
      primaryIconTheme: const IconThemeData(color: Color(0xFFA1A1A1)),
      // sliderTheme: SliderThemeData(),
      // tabBarTheme: TabBarTheme(),
      // tooltipTheme: TooltipThemeData(),
      // cardTheme: CardTheme(),
      // chipTheme: ChipThemeData.fromDefaults(
      //     secondaryColor: Colors.white,
      //     labelStyle: TextStyle(),
      // ),
      // platform: TargetPlatform.iOS,
      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // applyElevationOverlayColor: true,
      // pageTransitionsTheme: PageTransitionsTheme(),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFA1A1A1))),
      // scrollbarTheme: ScrollbarThemeData(),
      // bottomAppBarTheme: BottomAppBarTheme(),
      // colorScheme: ColorScheme(),
      // dialogTheme: DialogTheme(),
      // floatingActionButtonTheme: FloatingActionButtonThemeData(),
      // navigationRailTheme: NavigationRailThemeData(),
      typography: Typography(),
      // cupertinoOverrideTheme: NoDefaultCupertinoThemeData(),
      snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(color: Colors.white),
          backgroundColor: Color(0xFF202020)),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: Color(0xFF202020)),
      // popupMenuTheme: PopupMenuThemeData(),
      // bannerTheme: MaterialBannerThemeData(),
      // dividerColor: const Color(0xFFA1A1A1),
      dividerTheme: const DividerThemeData(
          color: Color(0xFF202020), thickness: 1, indent: 0, endIndent: 0),
      // buttonBarTheme: ButtonBarThemeData(),
      // bottomNavigationBarTheme: BottomNavigationBarThemeData(),
      // timePickerTheme: TimePickerThemeData(),
      // textButtonTheme: TextButtonThemeData(),
      // elevatedButtonTheme: ElevatedButtonThemeData(),
      // outlinedButtonTheme: OutlinedButtonThemeData(),
      // textSelectionTheme: TextSelectionThemeData(),
      // dataTableTheme: DataTableThemeData(),
      // checkboxTheme: CheckboxThemeData(),
      // radioTheme: RadioThemeData(),
      // switchTheme: SwitchThemeData(),
      // progressIndicatorTheme: ProgressIndicatorThemeData(),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData();
  }
}
