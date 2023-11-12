import 'package:advanced_icon/advanced_icon.dart';
import 'package:buscheck/screens/registration_page.dart';
import 'package:buscheck/services/auth.dart';
import 'package:buscheck/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.isAnonymous != true) {
      return Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(
                    FirebaseAuth.instance.currentUser!.displayName.toString()),
                accountEmail:
                    Text(FirebaseAuth.instance.currentUser!.email.toString())),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
              },
              child: const Text(
                'Sign out',
                style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
              ),
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
    } else if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
      return Drawer(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Text(
                  'Guest account',
                  style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Do you want an account?',
                  style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[400],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (cosntext) => const Registration()));
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
                  ),
                ),
              ],
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
                'Sign in / Registartion',
                style: TextStyle(fontFamily: 'LilitaOne', fontSize: 22),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (cosntext) => const Registration()));
              }),
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
