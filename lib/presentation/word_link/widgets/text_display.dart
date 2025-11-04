import 'package:flutter/material.dart';
import 'package:local_game/presentation/word_link/widgets/letter_container.dart';

class TextDisplay extends StatefulWidget {
  final List<String> words;
  const TextDisplay({super.key, required this.words});

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8, 
      children: [
        const SizedBox(height: 8),
        ..._buildWordDisplay(widget.words),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWordRow({required String word}) {
    final List<Widget> wordList = List.empty(growable: true);
    for (final letter in word.split('')) {
      wordList.addAll([
        LetterContainer(
          size:
              word.length > 6
                  ? LetterContainerSize.small
                  : LetterContainerSize.large,
          letter: letter == '-' ? '' : letter,
        ),
      ]);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        spacing: 8,
        children: [
          const SizedBox(width: 8),
          ...wordList,
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  List<Widget> _buildWordDisplay(List<String> filledWords) {
    return filledWords.map((word) => _buildWordRow(word: word)).toList();
  }
}
