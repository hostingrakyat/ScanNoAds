import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

final ValueNotifier<String> localeController = ValueNotifier<String>('en');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  localeController.value = prefs.getString('lang') ?? 'en';
  runApp(const ScanNoAdsApp());
}

Future<void> setLanguage(String lang) async {
  localeController.value = lang;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lang', lang);
}

class ScanNoAdsApp extends StatelessWidget {
  const ScanNoAdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeController,
      builder: (context, lang, _) {
        return L10nScope(
          lang: lang,
          child: MaterialApp(
            title: 'Scan No Ads',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
