import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/presentation/map/widget/life_widget.dart';
import 'package:local_game/presentation/map/widget/money_widget.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LifeWidget(),
                    MoneyWidget(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
