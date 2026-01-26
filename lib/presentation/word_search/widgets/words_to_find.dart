import 'package:flutter/material.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class WordsToFind extends StatefulWidget {
  final FindWordGameState state;
  final Color darkBorderColor;
  final Color accentOrange;

  const WordsToFind({
    super.key,
    required this.state,
    required this.darkBorderColor,
    required this.accentOrange,
  });

  @override
  State<WordsToFind> createState() => _WordsToFindState();
}

class _WordsToFindState extends State<WordsToFind> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: NeubrutalismContainer(
        borderRadius: 20,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: widget.darkBorderColor),
                const SizedBox(width: 8),
                Text(
                  'WORDS TO FIND',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: widget.darkBorderColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.state.foundWords.length}/${widget.state.wordsToFind.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: widget.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      widget.state.wordsToFind.map((word) {
                        bool isFound = widget.state.foundWords.contains(word);
                        Color wordColor =
                            widget.state.wordColors[word] ?? Colors.grey;

                        return Opacity(
                          opacity: isFound ? 0.5 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isFound
                                      ? wordColor.withOpacity(0.2)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isFound
                                        ? wordColor
                                        : widget.darkBorderColor,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isFound)
                                  Icon(Icons.check, size: 16, color: wordColor),
                                if (isFound) const SizedBox(width: 4),
                                Text(
                                  word,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        isFound
                                            ? wordColor
                                            : widget.darkBorderColor,
                                    decoration:
                                        isFound
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
