import 'package:buscheck/screens/menu.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_flutter/bus.dart';
import 'package:iconoir_flutter/bus_stop.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Bus Check',
          style: TextStyle(
              fontFamily: 'LilitaOne',
              fontSize: 25,
              color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.cyan[400],
        leading: const Icon(
          Icons.bus_alert_rounded,
          size: 30,
        ),
        elevation: 0,
      ),
      endDrawer: const Menu(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: height * 0.04, bottom: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.cyan[400],
                  child: Bus(
                    width: 35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.cyan[400],
                  child: Icon(
                    Icons.local_police_outlined,
                    size: 35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                FloatingActionButton(
                    onPressed: null,
                    backgroundColor: Colors.cyan[400],
                    child: BusStop(
                      width: 35,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
