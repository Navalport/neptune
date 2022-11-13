import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptune/dockings.dart';
import 'package:neptune/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neptune',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2F3136),
        cardColor: const Color(0xFF32353B),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: const Color(0xFFE4F8EF)),
        progressIndicatorTheme: Theme.of(context).progressIndicatorTheme.copyWith(color: const Color(0xFFF38D36)),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText1: TextStyle(fontSize: 16.0),
          bodyText2: TextStyle(fontSize: 12.0),
          subtitle1: TextStyle(fontSize: 12.0),
        ).apply(
          fontFamily: 'Inter',
          bodyColor: const Color(0xFFE4F8EF),
          displayColor: const Color(0xFFE4F8EF),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(const Color(0xFF32353B))).copyWith(
          secondary: const Color(0xFFF38D36),
        ),
        radioTheme: RadioThemeData(
            fillColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected) ? const Color(0xFFF38D36) : const Color(0xFFE4F8EF))),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF292B2F),
          labelStyle: TextStyle(
            color: Color(0xFFE4F8EF),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF36393F),
            ),
          ),
        ),
      ),
      home: const DockingsWidget(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
