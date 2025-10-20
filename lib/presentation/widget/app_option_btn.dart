import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/constants/app_assets.dart';

class AppOptionBtn extends StatefulWidget {
  final Function onClick;
  final bool isSelected;
  final String title;
  const AppOptionBtn({
    super.key,
    required this.onClick,
    required this.title,
    required this.isSelected,
  });

  @override
  State<AppOptionBtn> createState() => _AppOptionBtnState();
}

class _AppOptionBtnState extends State<AppOptionBtn> {
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
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(AppAssets.inputSvg, fit: BoxFit.fill),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            AppAssets.circleSvg,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                widget.isSelected
                                    ? Colors.green
                                    : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.body.copyWith(
                          color: AppTheme.accentGreen,
                          fontSize: 20,
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
