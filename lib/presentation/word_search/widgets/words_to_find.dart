import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

class WordsToFind extends StatefulWidget {
  final FindWordGameState state;
  const WordsToFind({super.key, required this.state});

  @override
  State<WordsToFind> createState() => _WordsToFindState();
}

class _WordsToFindState extends State<WordsToFind> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Words to Find:',
              style: AppTextStyles.tileLetter.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    widget.state.wordsToFind.map((word) {
                      bool isFound = widget.state.foundWords.contains(word);
                      Color wordColor =
                          widget.state.wordColors[word] ?? Colors.grey;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              AppAssets.inputSvg,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              word,
                              style: AppTextStyles.keyboardKey.copyWith(
                                decoration:
                                    isFound ? TextDecoration.lineThrough : null,
                                color:
                                    isFound
                                        ? wordColor.withAlpha(100)
                                        : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
