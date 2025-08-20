import 'package:flutter/material.dart';

class AppKeyboard extends StatefulWidget {
  final List<String> letters;
  const AppKeyboard({super.key, required this.letters});

  @override
  State<AppKeyboard> createState() => _AppKeyboardState();
}

class _AppKeyboardState extends State<AppKeyboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
