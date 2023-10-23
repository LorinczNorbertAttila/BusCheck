import 'package:buscheck/screens/menu.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bus Check',
          style: TextStyle(fontFamily: 'LilitaOne', fontSize: 20),
        ),
        backgroundColor: Colors.cyan[400],
        leading: const Icon(Icons.bus_alert_rounded),
      ),
      endDrawer: const Menu(),
    );
  }
}
