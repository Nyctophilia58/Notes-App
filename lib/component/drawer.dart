import 'package:flutter/material.dart';
import 'package:notes/component/drawer_tile.dart';
import 'package:notes/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: const DividerThemeData(color: Colors.transparent),
            ),
            child: DrawerHeader(child:
              DrawerHeader(
                child: Icon(
                  Icons.note,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 2,
            indent: 20.0,
            endIndent: 20.0,
          ),

          DrawerTile(
            title: 'Notes',
            icon: Icons.note,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          DrawerTile(
            title: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage()
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}