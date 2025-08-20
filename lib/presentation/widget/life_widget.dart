import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

class LifeWidget extends StatelessWidget {
  const LifeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(height: 30, color: AppTheme.primaryGold),
                ),
                Expanded(
                  child: Container(
                    height: 30,
                    color: AppTheme.wrongPositionTile,
                  ),
                ),
                Expanded(
                  child: Container(height: 30, color: AppTheme.primaryGold),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.wrongPositionTile,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.primaryGold,
            ),
            child: Center(child: Text('5', style: AppTextStyles.heading1)),
          ),
        ],
      ),
    );
  }
}
