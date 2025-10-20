import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/core/constants/app_assets.dart';

class GameTopBar extends StatelessWidget {
  final int points;
  final int hints;
  final Function? onHintClicked;
  const GameTopBar({
    super.key,
    required this.points,
    required this.hints,
    this.onHintClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(AppAssets.inputSvg, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset(height: 40, width: 40, AppAssets.coinSvg),
                  const SizedBox(width: 4),
                  Text(
                    points.toString(),
                    style: AppTextStyles.body.copyWith(
                      color: AppTheme.accentGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: onHintClicked != null,
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  onHintClicked!();
                },
                child: SvgPicture.asset(
                  AppAssets.hintSvg,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: SvgPicture.asset(
                  AppAssets.settingsSvg,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
