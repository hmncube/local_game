import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/routes.dart';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go(Routes.mapScreen.toPath),
                    child: SvgPicture.asset(
                      height: 40,
                      width: 40,
                      AppAssets.homeSvg,
                    ),
                  ),

                  Row(
                    children: [
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        height: 30,
                        width: 20,
                        AppAssets.coinSvg,
                      ),
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
                  GestureDetector(
                    onTap:
                        onHintClicked != null
                            ? () {
                              onHintClicked!();
                            }
                            : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.hintSvg,
                          height: 30,
                          width: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: Text(
                            hints.toString(),
                            style: AppTextStyles.body.copyWith(
                              color: AppTheme.accentGreen,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      child: SvgPicture.asset(
                        AppAssets.settingsSvg,
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
