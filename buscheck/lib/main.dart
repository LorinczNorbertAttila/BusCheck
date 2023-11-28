
import 'package:buscheck/screens/bus_page/bus_list.dart';
import 'package:buscheck/screens/home/home_page.dart';
import 'package:buscheck/screens/home/menu.dart';
import 'package:buscheck/screens/registration&sign_in/registration_page.dart';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            initialRoute: '/home',
            routes: {
              '/home': (context) => const Home(),
              '/signin': (context) => const SignIn(),
              '/register': (context) => const Registration(),
              '/menu': (context) => const Menu(),
              '/buslist': (context) => const BusList(),
            },
            home: const Home());
      });
}
