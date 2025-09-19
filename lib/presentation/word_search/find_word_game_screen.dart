import 'package:flutter/material.dart';
import 'dart:math';

import 'package:local_game/app/themes/app_text_styles.dart';

class FindWordGameScreen extends StatefulWidget {
  const FindWordGameScreen({super.key});

  @override
  State<FindWordGameScreen> createState() => _FindWordGameScreenState();
}

class _FindWordGameScreenState extends State<FindWordGameScreen> {
  int gridSize = 10;
  List<List<String>> grid = [];
  List<String> wordsToFind = [];
  List<String> foundWords = [];
  List<Position> selectedPositions = [];
  Position? startPosition;
  bool isDragging = false;
  Map<String, List<Position>> wordPositions = {};
  Map<String, Color> wordColors = {};

  // Sample words for the game
  final List<String> sampleWords = [
    'FLUTTER',
    'DART',
    'MOBILE',
    'APP',
    'CODE',
    'WIDGET',
    'STATE',
    'BUILD',
    'SCREEN',
    'GAME',
    'WORD',
    'FIND',
  ];

  // Predefined colors for found words
  final List<Color> availableColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    wordsToFind = sampleWords.take(6).toList();
    foundWords.clear();
    selectedPositions.clear();
    wordPositions.clear();
    wordColors.clear();

    // Place words in the grid
    placeWords();

    // Fill empty cells with random letters
    fillEmptyCells();

    setState(() {});
  }

  void placeWords() {
    Random random = Random();

    for (String word in wordsToFind) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 100) {
        int direction = random.nextInt(8); // 8 directions
        Position startPos = Position(
          random.nextInt(gridSize),
          random.nextInt(gridSize),
        );

        if (canPlaceWord(word, startPos, direction)) {
          placeWord(word, startPos, direction);
          placed = true;
        }
        attempts++;
      }
    }
  }

  bool canPlaceWord(String word, Position start, int direction) {
    List<int> dx = [-1, -1, -1, 0, 0, 1, 1, 1];
    List<int> dy = [-1, 0, 1, -1, 1, -1, 0, 1];

    for (int i = 0; i < word.length; i++) {
      int newX = start.row + (dx[direction] * i);
      int newY = start.col + (dy[direction] * i);

      if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize) {
        return false;
      }

      if (grid[newX][newY].isNotEmpty && grid[newX][newY] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void placeWord(String word, Position start, int direction) {
    List<int> dx = [-1, -1, -1, 0, 0, 1, 1, 1];
    List<int> dy = [-1, 0, 1, -1, 1, -1, 0, 1];

    List<Position> positions = [];

    for (int i = 0; i < word.length; i++) {
      int newX = start.row + (dx[direction] * i);
      int newY = start.col + (dy[direction] * i);
      grid[newX][newY] = word[i];
      positions.add(Position(newX, newY));
    }

    // Store the positions for this word
    wordPositions[word] = positions;
  }

  void fillEmptyCells() {
    Random random = Random();
    String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void onCellTap(int row, int col) {
    Position position = Position(row, col);

    if (!isDragging) {
      // Start selection
      startPosition = position;
      selectedPositions = [position];
      isDragging = true;
    }

    setState(() {});
  }

  void onCellDrag(int row, int col) {
    if (!isDragging || startPosition == null) return;

    Position currentPos = Position(row, col);
    selectedPositions = getLinePositions(startPosition!, currentPos);

    setState(() {});
  }

  void onDragEnd() {
    if (selectedPositions.length > 1) {
      String selectedWord = selectedPositions
          .map((pos) => grid[pos.row][pos.col])
          .join('');

      String reversedWord = selectedWord.split('').reversed.join('');

      // Check if the selected word matches any word to find
      String? matchedWord;
      if (wordsToFind.contains(selectedWord) &&
          !foundWords.contains(selectedWord)) {
        matchedWord = selectedWord;
      } else if (wordsToFind.contains(reversedWord) &&
          !foundWords.contains(reversedWord)) {
        matchedWord = reversedWord;
      }

      if (matchedWord != null) {
        foundWords.add(matchedWord);

        // Assign a color to the found word
        int colorIndex = foundWords.length - 1;
        wordColors[matchedWord] =
            availableColors[colorIndex % availableColors.length];

        // Show a brief success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found: $matchedWord!'),
            duration: const Duration(seconds: 1),
            backgroundColor: wordColors[matchedWord],
          ),
        );
      }
    }

    selectedPositions.clear();
    startPosition = null;
    isDragging = false;

    setState(() {});
  }

  List<Position> getLinePositions(Position start, Position end) {
    List<Position> positions = [];

    int dx = (end.row - start.row).sign;
    int dy = (end.col - start.col).sign;

    // Only allow straight lines (horizontal, vertical, diagonal)
    if (dx != 0 &&
        dy != 0 &&
        (end.row - start.row).abs() != (end.col - start.col).abs()) {
      return [start]; // Invalid line, return just start position
    }

    int currentRow = start.row;
    int currentCol = start.col;

    while (currentRow != end.row + dx || currentCol != end.col + dy) {
      if (currentRow >= 0 &&
          currentRow < gridSize &&
          currentCol >= 0 &&
          currentCol < gridSize) {
        positions.add(Position(currentRow, currentCol));
      }

      if (currentRow == end.row && currentCol == end.col) break;

      currentRow += dx;
      currentCol += dy;
    }

    return positions;
  }

  Color getCellColor(int row, int col) {
    Position pos = Position(row, col);

    if (selectedPositions.contains(pos)) {
      return Colors.blue.withOpacity(0.5);
    }

    // Check if this position is part of a found word and return its specific color
    for (String word in foundWords) {
      if (wordPositions[word]?.contains(pos) == true) {
        Color wordColor = wordColors[word] ?? Colors.green;
        return wordColor.withOpacity(0.4);
      }
    }

    return Colors.grey.shade200;
  }

  bool isPartOfFoundWord(Position pos, String word) {
    return wordPositions[word]?.contains(pos) == true;
  }

  void showCustomizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempGridSize = gridSize;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Customize Game'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Grid Size: ${tempGridSize}x$tempGridSize'),
                  Slider(
                    value: tempGridSize.toDouble(),
                    min: 6,
                    max: 15,
                    divisions: 9,
                    label: tempGridSize.toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempGridSize = value.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gridSize = tempGridSize;
                    });
                    Navigator.of(context).pop();
                    initializeGame();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Word'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: showCustomizeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: initializeGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game grid
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double gridWidth = constraints.maxWidth;
                      double gridHeight = constraints.maxHeight;
                      double cellSize = min(gridWidth, gridHeight) / gridSize;

                      return GestureDetector(
                        onPanStart: (details) {
                          RenderBox box =
                              context.findRenderObject() as RenderBox;
                          Offset localOffset = box.globalToLocal(
                            details.globalPosition,
                          );

                          int row = (localOffset.dy / cellSize).floor();
                          int col = (localOffset.dx / cellSize).floor();

                          if (row >= 0 &&
                              row < gridSize &&
                              col >= 0 &&
                              col < gridSize) {
                            onCellTap(row, col);
                          }
                        },
                        onPanUpdate: (details) {
                          RenderBox box =
                              context.findRenderObject() as RenderBox;
                          Offset localOffset = box.globalToLocal(
                            details.globalPosition,
                          );

                          int row = (localOffset.dy / cellSize).floor();
                          int col = (localOffset.dx / cellSize).floor();

                          if (row >= 0 &&
                              row < gridSize &&
                              col >= 0 &&
                              col < gridSize) {
                            onCellDrag(row, col);
                          }
                        },
                        onPanEnd: (_) => onDragEnd(),
                        child: SizedBox(
                          width: cellSize * gridSize,
                          height: cellSize * gridSize,
                          child: Column(
                            children: List.generate(gridSize, (row) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(gridSize, (col) {
                                    return Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: getCellColor(row, col),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            grid[row][col],
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: cellSize * 0.4,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Words to find
            Expanded(
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
                      style: AppTextStyles.tileLetter.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            wordsToFind.map((word) {
                              bool isFound = foundWords.contains(word);
                              Color wordColor = wordColors[word] ?? Colors.grey;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isFound
                                          ? wordColor.withOpacity(0.2)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        isFound
                                            ? wordColor
                                            : Colors.grey.shade400,
                                  ),
                                ),
                                child: Text(
                                  word,
                                  style: AppTextStyles.keyboardKey.copyWith(
                                    decoration:
                                        isFound
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        isFound
                                            ? wordColor.withAlpha(100)
                                            : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}
