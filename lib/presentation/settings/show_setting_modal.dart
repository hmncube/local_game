import 'package:flutter/material.dart';
import 'package:local_game/presentation/settings/settings_screen.dart';

Future<void> showSettingModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text('Settings'),
        ),
        content: SettingsScreen(),
      );
    },
  );
}
