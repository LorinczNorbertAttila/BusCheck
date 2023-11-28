import 'package:buscheck/screens/home/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class myThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey[850],
      primaryColor: Colors.black,
      colorScheme: const ColorScheme.dark(primary: Colors.white),
      iconTheme: const IconThemeData(color: Colors.black));

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.light(primary: Colors.black),
      iconTheme: const IconThemeData(color: Colors.white));
}

class ChangeTheme extends StatelessWidget {
  const ChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Switch.adaptive(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(value);
          final mapScreenState =
              context.findAncestorStateOfType<MapScreenState>();
          mapScreenState?.setMapStyle();
        });
  }
}
