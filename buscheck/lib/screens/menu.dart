import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              size: 30,
            ),
            title: Text(
              'Sign in/Registartion',
              style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
            ),
            onTap: null,
          )
        ],
      ),
    );
  }
}
