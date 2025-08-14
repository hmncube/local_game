import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';

class MoneyWidget extends StatelessWidget {
  const MoneyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 20),
          child: Container(
            height: 30,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
          child: Align(
          alignment: Alignment.center,
          child: Text('24', style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),),
        ),
          ),

        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryGold,
            borderRadius: BorderRadius.circular(20)
          ),
          height: 40,
          width: 40,
          child: Center(
            child: Icon(Icons.money,),
          ),
        ),
        
      ],
    );
  }
}
