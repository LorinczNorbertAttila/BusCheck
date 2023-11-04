import 'package:buscheck/screens/home_page.dart';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
            title: 'Bus Check',
            themeMode: themeProvider.themeMode,
            theme: myThemes.lightTheme,
            darkTheme: myThemes.darkTheme,
            home: const Home());
      });
}
