import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/presentation/game/widgets/letter_container.dart';
import 'package:local_game/presentation/game/widgets/letters_keyboard.dart';
import 'package:local_game/presentation/widget/life_widget.dart';
import 'package:local_game/presentation/widget/money_widget.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(children: [LifeWidget(), Spacer(), MoneyWidget()]),
              const SizedBox(height: 60),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Spacer(),
                        LetterContainer(letter: 'I'),
                        const SizedBox(width: 32),
                        LetterContainer(letter: 'T'),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Spacer(),
                        LetterContainer(letter: 'I'),
                        const SizedBox(width: 32),
                        LetterContainer(letter: 'F'),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Spacer(),
                        LetterContainer(letter: 'F'),
                        const SizedBox(width: 32),
                        LetterContainer(letter: 'I'),
                        const SizedBox(width: 32),
                        LetterContainer(letter: 'T'),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              Spacer(),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('FIT', style: AppTextStyles.heading1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LettersKeyboard(
                enabledLetters: ['F', 'I', 'T'],
                onKeyPressed: (letter) {
                  // Handle key press
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
