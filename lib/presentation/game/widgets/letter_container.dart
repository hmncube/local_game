import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';

class LetterContainer extends StatefulWidget {
  final String letter;
  const LetterContainer({super.key, required this.letter});

  @override
  State<LetterContainer> createState() => _LetterContainerState();
}

class _LetterContainerState extends State<LetterContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(widget.letter, style: AppTextStyles.heading1)),
    );
  }
}
