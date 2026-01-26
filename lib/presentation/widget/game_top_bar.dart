import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class GameTopBar extends StatelessWidget {
  final int points;
  final int hints;
  final Function? onHintClicked;
  final bool showHome;

  const GameTopBar({
    super.key,
    required this.points,
    required this.hints,
    this.onHintClicked,
    this.showHome = true,
  });

  @override
  Widget build(BuildContext context) {
    const darkBorderColor = Color(0xFF2B2118);

    return NeubrutalismContainer(
      borderRadius: 15,
      borderWidth: 3,
      shadowOffset: const Offset(0, 4),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showHome)
            GestureDetector(
              onTap: () => context.go(Routes.mapScreen.toPath),
              child: SvgPicture.asset(
                AppAssets.homeSvg,
                height: 24,
                width: 24,
                color: darkBorderColor,
              ),
            ),

          // Points
          Row(
            children: [
              SvgPicture.asset(AppAssets.coinSvg, height: 24, width: 24),
              const SizedBox(width: 6),
              Text(
                points.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: darkBorderColor,
                ),
              ),
            ],
          ),

          // Hints
          GestureDetector(
            onTap: onHintClicked != null ? () => onHintClicked!() : null,
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.hintSvg, height: 24, width: 24),
                const SizedBox(width: 4),
                Text(
                  hints.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: darkBorderColor,
                  ),
                ),
              ],
            ),
          ),

          // Settings
          GestureDetector(
            onTap: () => context.pushNamed(Routes.settings.toNamed),
            child: SvgPicture.asset(
              AppAssets.settingsSvg,
              height: 24,
              width: 24,
              color: darkBorderColor,
            ),
          ),
        ],
      ),
    );
  }
}
