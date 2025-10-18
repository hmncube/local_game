import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/constants/app_assets.dart';

class AppTextInput extends StatefulWidget {
  final Function onTextChanged;
  const AppTextInput({super.key, required this.onTextChanged,});

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(AppAssets.inputSvg, fit: BoxFit.fill),
            ),
            Center(
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: SvgPicture.asset(
                      AppAssets.pencilSvg,
                      height: 30,
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: TextField(
                        onChanged: (String text){widget.onTextChanged(text);},
                        cursorColor: AppTheme.accentGreen,
                        cursorHeight: 24,
                        style: AppTextStyles.body.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
