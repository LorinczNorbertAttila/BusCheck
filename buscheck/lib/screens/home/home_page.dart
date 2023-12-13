import 'package:buscheck/screens/home/map.dart';
import 'package:buscheck/screens/home/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconoir_flutter/bus.dart';
import 'package:iconoir_flutter/bus_stop.dart';
import 'package:buscheck/screens/home/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey<MapScreenState>();

  void _addUserTime() {
    MapScreenState? mapScreenState = _mapScreenKey.currentState;
    mapScreenState?.addControllerTimeMarker();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User time added!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //double height = MediaQuery.of(context).size.height;
    //double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Bus Check',
          style: TextStyle(
              fontFamily: 'LilitaOne',
              fontSize: 32,
              color: Theme.of(context).primaryColor),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.yellow)
            .animate() // this wraps the previous Animate in another Animate
            .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
            .slide(),
        backgroundColor: Colors.cyan[400],
        leading: const Icon(
          Icons.bus_alert_rounded,
          size: 32,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.yellow)
            .animate() // this wraps the previous Animate in another Animate
            .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
            .slide(),
        elevation: 0,
      ),
      endDrawer: const Menu(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ignore: prefer_const_constructors
          // MapScreen(),
          MapScreen(key: _mapScreenKey, addUserTimeCallback: _addUserTime),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Navigator.pushNamed(context, '/buslist');
                },
                backgroundColor: Colors.cyan[400],
                child: Bus(
                  width: 35,
                  color: Theme.of(context).primaryColor,
                ),
              )
                  .animate()
                  .scaleXY(
                      duration: const Duration(seconds: 3),
                      end: 1.15,
                      curve: Curves.easeOutBack)
                  .moveY(duration: const Duration(seconds: 3), end: -10)
                  .elevation(duration: const Duration(seconds: 3), end: 24),
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  _mapScreenKey.currentState?.addUserTimeCallback();
                },
                backgroundColor: Colors.cyan[400],
                child: Icon(
                  Icons.local_police_outlined,
                  size: 35,
                  color: Theme.of(context).primaryColor,
                ),
              )
                  .animate()
                  .scaleXY(
                      duration: const Duration(seconds: 3),
                      end: 1.15,
                      curve: Curves.easeOutBack)
                  .moveY(duration: const Duration(seconds: 3), end: -10)
                  .elevation(duration: const Duration(seconds: 3), end: 24),
              FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SearchBus()), // Itt helyettesítsd be a saját kereső osztályodat
                        );
                      },
                      backgroundColor: Colors.cyan[400],
                      child: BusStop(
                        width: 35,
                        color: Theme.of(context).primaryColor,
                      ))
                  .animate()
                  .scaleXY(
                      duration: const Duration(seconds: 3),
                      end: 1.15,
                      curve: Curves.easeOutBack)
                  .moveY(duration: const Duration(seconds: 3), end: -10)
                  .elevation(duration: const Duration(seconds: 3), end: 24),
            ],
          )
        ],
      ),
    );
  }
}
