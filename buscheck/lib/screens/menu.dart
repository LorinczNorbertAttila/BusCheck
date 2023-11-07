import 'package:advanced_icon/advanced_icon.dart';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(
                    FirebaseAuth.instance.currentUser!.displayName.toString()),
                accountEmail:
                    Text(FirebaseAuth.instance.currentUser!.email.toString())),
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
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
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
