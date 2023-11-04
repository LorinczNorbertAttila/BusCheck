import 'package:advanced_icon/advanced_icon.dart';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Sign in/Registartion',
              style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
            ),
            onTap: null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AdvancedIcon(
                icon: Icons.light_mode,
                secondaryIcon: Icons.dark_mode,
                state: Theme.of(context).brightness == Brightness.dark
                    ? AdvancedIconState.secondary
                    : AdvancedIconState.primary,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Text(
                'Change Theme:',
                style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
              ),
              const ChangeTeheme(),
            ],
          )
        ],
      ),
    );
  }
}
