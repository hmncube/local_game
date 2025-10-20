import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';

class AppBtn extends StatefulWidget {
  final Function onClick;
  final bool isEnabled;
  final String title;
  const AppBtn({
    super.key,
    required this.onClick,
    required this.title,
    required this.isEnabled,
  });

  @override
  State<AppBtn> createState() => _AppBtnState();
}

class _AppBtnState extends State<AppBtn> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onClick();
      },
      child: SizedBox(
        height: 60,
        width: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(AppAssets.btnGreenSvg, fit: BoxFit.fill),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
