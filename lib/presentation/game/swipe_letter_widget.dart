import 'package:flutter/material.dart';

class SwipeLetterWidget extends StatefulWidget {
  final List<String> availableLetters;
  final String currentWord;
  final Function(String) onLetterTap;
  final Function(List<String>) onSwipeComplete;

  const SwipeLetterWidget({
    super.key,
    required this.availableLetters,
    required this.currentWord,
    required this.onLetterTap,
    required this.onSwipeComplete,
  });

  @override
  State<SwipeLetterWidget> createState() => _SwipeLetterWidgetState();
}

class _SwipeLetterWidgetState extends State<SwipeLetterWidget> {
  List<String> swipedLetters = [];
  bool isSwipping = false;
  Set<String> highlightedLetters = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            isSwipping = true;
            swipedLetters.clear();
            highlightedLetters.clear();
          });
          _handlePanUpdate(details.localPosition);
        },
        onPanUpdate: (details) {
          if (isSwipping) {
            _handlePanUpdate(details.localPosition);
          }
        },
        onPanEnd: (details) {
          if (isSwipping) {
            setState(() {
              isSwipping = false;
              highlightedLetters.clear();
            });
            if (swipedLetters.isNotEmpty) {
              widget.onSwipeComplete(swipedLetters);
            }
          }
        },
        onPanCancel: () {
          setState(() {
            isSwipping = false;
            highlightedLetters.clear();
            swipedLetters.clear();
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.availableLetters.asMap().entries.map((entry) {
            int index = entry.key;
            String letter = entry.value;
            bool isSelected = widget.currentWord.contains(letter);
            bool isHighlighted = highlightedLetters.contains(letter);
            
            return Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () => widget.onLetterTap(letter),
                  child: Container(
                    key: GlobalKey(),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isHighlighted 
                          ? Colors.brown.shade700
                          : isSelected 
                              ? Colors.brown.shade600 
                              : Colors.brown.shade300,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHighlighted ? Colors.brown.shade900 : Colors.brown,
                        width: isHighlighted ? 3 : 2,
                      ),
                      boxShadow: isHighlighted ? [
                        BoxShadow(
                          color: Colors.brown.shade800.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: (isSelected || isHighlighted) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handlePanUpdate(Offset localPosition) {
    // Calculate which letter container the touch is over
    final containerWidth = 60.0;
    final totalWidth = MediaQuery.of(context).size.width - 40; // Account for padding
    final spacing = (totalWidth - (containerWidth * widget.availableLetters.length)) / 
                   (widget.availableLetters.length - 1);
    
    // Find the letter index based on position
    final adjustedX = localPosition.dx - 20; // Account for container padding
    
    for (int i = 0; i < widget.availableLetters.length; i++) {
      final letterStartX = i * (containerWidth + spacing);
      final letterEndX = letterStartX + containerWidth;
      
      if (adjustedX >= letterStartX && adjustedX <= letterEndX) {
        final letter = widget.availableLetters[i];
        
        if (!swipedLetters.contains(letter)) {
          setState(() {
            swipedLetters.add(letter);
            highlightedLetters.add(letter);
          });
        }
        break;
      }
    }
  }
}
