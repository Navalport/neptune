import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mooringapp/login2.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();
  await Amplify.addPlugin(authPlugin);

  try {
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    safePrint("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mooringapp',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2F3136),
        cardColor: const Color(0xFF32353B),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: const Color(0xFFE4F8EF)),
        progressIndicatorTheme: Theme.of(context).progressIndicatorTheme.copyWith(color: const Color(0xFFF38D36)),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline5: TextStyle(fontSize: 36.0),
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
        dialogBackgroundColor: const Color(0xFF32353B),
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
      home: const LoginWidget(),
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
