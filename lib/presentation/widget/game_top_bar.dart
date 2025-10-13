import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/presentation/settings/show_setting_modal.dart';

class GameTopBar extends StatelessWidget {
  final int points;
  final int hints;
  final Function onHintClicked;
  const GameTopBar({
    super.key,
    required this.points,
    required this.hints,
    required this.onHintClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 20),
              child: Container(
                height: 30,
                width: 150,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    points.toString(),
                    style: AppTextStyles.keyboardKey.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 40,
              width: 40,
              child: Center(child: SvgPicture.asset(AppAssets.coinSvg)),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          child: Row(
            children: [SvgPicture.asset(AppAssets.hintSvg), Text('$hints')],
          ),
          onTap: () {
            onHintClicked();
          },
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            showSettingModal(context);
          },
          child: SvgPicture.asset(AppAssets.settingsSvg, width: 40, height: 40),
        ),
      ],
    );
  }
}
