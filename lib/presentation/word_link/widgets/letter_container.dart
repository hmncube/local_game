import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';

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
    return SizedBox(
      width: 50,
      height: 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(AppAssets.btnGreenSvg, fit: BoxFit.fill),
          ),
          Center(child: Text(widget.letter, style: AppTextStyles.heading1)),
        ],
      ),
    );
  }
}

enum LetterContainerSize { small, large }
