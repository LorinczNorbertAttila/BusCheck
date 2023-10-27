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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bus Check',
          style: TextStyle(fontFamily: 'LilitaOne', fontSize: 25),
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
          const SearchBar(
            leading: Icon(Icons.search),
            //backgroundColor: Colors.grey,
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width * 0.1, height * 0.02, width * 0.095, height * 0.02),
                child: FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.cyan[400],
                  child: const Bus(
                    color: Colors.white,
                    width: 35,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width * 0.1, height * 0.02, width * 0.095, height * 0.02),
                child: FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.cyan[400],
                  child: const Icon(
                    Icons.local_police_outlined,
                    size: 35,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width * 0.1, height * 0.02, width * 0.1, height * 0.02),
                child: FloatingActionButton(
                    onPressed: null,
                    backgroundColor: Colors.cyan[400],
                    child: const BusStop(
                      color: Colors.white,
                      width: 35,
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
