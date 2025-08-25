import 'package:flutter/material.dart';
import 'package:local_game/presentation/game/widgets/letter_container.dart';

class TextDisplay extends StatefulWidget {
  final List<String> words;
  const TextDisplay({
    super.key,
    required this.words,
  });

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 16,
        children: [
          const SizedBox(height: 16),
          ... _buildWordDisplay(widget.words),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWordRow(String word) {
    final List<Widget> wordList = List.empty(growable: true);
    for (final letter in word.split('')) {
      wordList.addAll([
        LetterContainer(letter: letter == '-' ? '' : letter),
      ]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 8,
      children: [
        Spacer(),
        ...wordList,
        Spacer(),
      ],
    );
  }
  
  List<Widget> _buildWordDisplay(List<String> filledWords) {
    return filledWords.map((word) => _buildWordRow(word)).toList();
  }
}
