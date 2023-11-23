import 'package:buscheck/models/bus.dart';
import 'package:buscheck/screens/bus/bus_tile.dart';
import 'package:buscheck/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Bus>>.value(
      value: DatabaseService().buses,
      initialData: [],
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: const Text(
            'Bus List',
            style: TextStyle(
                fontFamily: 'LilitaOne', fontSize: 25, color: Colors.white),
          ),
          backgroundColor: Colors.cyan[400],
          elevation: 0.0,
        ),
        body: const BusList(),
      ),
    );
  }
}

class BusList extends StatefulWidget {
  const BusList({super.key});

  @override
  _BusListState createState() => _BusListState();
}

class _BusListState extends State<BusList> {
  @override
  Widget build(BuildContext context) {
    final bus = Provider.of<List<Bus>>(context);

    return ListView.builder(
      itemCount: bus.length,
      itemBuilder: (context, index) {
        return BusTile(bus: bus[index]);
      },
    );
  }
}
