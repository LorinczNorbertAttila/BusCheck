import 'package:buscheck/models/bus.dart';
import 'package:flutter/material.dart';

class BusTile extends StatelessWidget {
  final Bus bus;
  const BusTile({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            child: Text(bus.id),
          ),
          title: Text(bus.rating.toString()),
        ),
      ),
    );
  }
}
