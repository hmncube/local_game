import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

class HintWidget extends StatelessWidget {
  final Function showHint;
  final int hints;
  const HintWidget({super.key, required this.showHint, required this.hints});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => showHint(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb, color: AppTheme.primaryGold, size: 40),
            const SizedBox(width: 2),
            Text(
              hints.toString(),
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
