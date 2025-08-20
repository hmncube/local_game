import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  List<String> availableLetters = ['I', 'T', 'F'];
  List<String> currentWord = [];
  List<List<String>> grid = [
    ['', ''], // First row - 'I' is revealed
    ['', ''], // Second row
    ['', '', ''], // Third row
  ];

  // Valid words for this level
  Map<String, List<int>> validWords = {
    'IT': [0, 1], // Row 0, positions 0,1
    'FIT': [2, 0], // Row 2, positions 0,1,2
  };

  int level = 3;
  int gems = 66;

  @override
  void initState() {
    super.initState();
    // Initialize grid with known letters
    // grid[0][0] = 'I'; // First letter is already revealed
  }

  void onLetterTap(String letter) {
    setState(() {
      if (!currentWord.contains(letter)) {
        currentWord.add(letter);
        checkForValidWord();
      }
    });
  }

  void checkForValidWord() {
    String word = currentWord.join();
    if (validWords.containsKey(word)) {
      // Valid word found, place it on grid
      List<int> position = validWords[word]!;
      int row = position[0];
      int startCol = position[1];

      setState(() {
        for (int i = 0; i < word.length; i++) {
          if (row == 2) {
            // Third row
            grid[row][startCol + i] = word[i];
          } else {
            // First or second row
            grid[row][startCol + i] = word[i];
          }
        }
        currentWord.clear();
      });
    }
  }

  void resetCurrentWord() {
    setState(() {
      currentWord.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                  // Level
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level $level',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  // Gems
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.cyan),
                      const SizedBox(width: 4),
                      Text(
                        '$gems',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Plus button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Game grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown, width: 3),
              ),
              child: Column(
                children: [
                  // First row (2 boxes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGridBox(
                        grid[0][0],
                        isRevealed: grid[0][0].isNotEmpty,
                      ),
                      const SizedBox(width: 10),
                      _buildGridBox(
                        grid[0][1],
                        isRevealed: grid[0][1].isNotEmpty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Second row (2 boxes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGridBox(
                        grid[1][0],
                        isRevealed: grid[1][0].isNotEmpty,
                      ),
                      const SizedBox(width: 10),
                      _buildGridBox(
                        grid[1][1],
                        isRevealed: grid[1][1].isNotEmpty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Third row (3 boxes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGridBox(
                        grid[2][0],
                        isRevealed: grid[2][0].isNotEmpty,
                      ),
                      const SizedBox(width: 10),
                      _buildGridBox(
                        grid[2][1],
                        isRevealed: grid[2][1].isNotEmpty,
                      ),
                      const SizedBox(width: 10),
                      _buildGridBox(
                        grid[2][2],
                        isRevealed: grid[2][2].isNotEmpty,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Current word display
            if (currentWord.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.brown.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current: ${currentWord.join()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    availableLetters.map((letter) {
                      bool isSelected = currentWord.contains(letter);
                      return GestureDetector(
                        onTap: () => onLetterTap(letter),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.brown.shade600
                                    : Colors.brown.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.brown, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hint button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb, color: Colors.white),
                        SizedBox(width: 4),
                        Text('60', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  // Reset button
                  GestureDetector(
                    onTap: resetCurrentWord,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh, color: Colors.white),
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

  Widget _buildGridBox(String letter, {required bool isRevealed}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isRevealed ? Colors.brown.shade200 : Colors.brown.shade400,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade600, width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isRevealed ? Colors.black : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
