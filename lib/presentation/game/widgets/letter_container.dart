import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';

class LetterContainer extends StatefulWidget {
  final String letter;
  final LetterContainerSize size;
  const LetterContainer({
    super.key,
    required this.letter,
    this.size = LetterContainerSize.large,
  });

  @override
  State<LetterContainer> createState() => _LetterContainerState();
}

class _LetterContainerState extends State<LetterContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size == LetterContainerSize.small ? 50 : 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(widget.letter, style: AppTextStyles.heading1)),
    );
  }
}

enum LetterContainerSize { small, large }
