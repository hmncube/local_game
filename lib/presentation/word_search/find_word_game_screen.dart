import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/presentation/word_search/find_word_game_cubit.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';
import 'dart:math';

class FindWordGameScreen extends StatefulWidget {
  const FindWordGameScreen({super.key});

  @override
  State<FindWordGameScreen> createState() => _FindWordGameScreenState();
}

class _FindWordGameScreenState extends State<FindWordGameScreen> {
  late final FindWordGameCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<FindWordGameCubit>();
    _cubit.initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FindWordGameCubit, FindWordGameState>(
        listener: (context, state) {
          if (state.newFoundWord.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found: ${state.newFoundWord}!'),
                duration: const Duration(seconds: 1),
                backgroundColor: state.wordColors[state.newFoundWord],
              ),
            );
            _cubit.clearNewFoundWord();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGameGrid(state),
                  const SizedBox(height: 16),
                  _buildWordsToFind(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameGrid(FindWordGameState state) {
    if (state.grid.isEmpty) {
      return const Expanded(
        flex: 2,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Expanded(
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
              double cellSize = min(gridWidth, gridHeight) / state.gridSize;

              return GestureDetector(
                onPanStart: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(details.globalPosition);
                  int row = (localOffset.dy / cellSize).floor();
                  int col = (localOffset.dx / cellSize).floor();
                  if (row >= 0 && row < state.gridSize && col >= 0 && col < state.gridSize) {
                    _cubit.onCellTap(row, col);
                  }
                },
                onPanUpdate: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(details.globalPosition);
                  int row = (localOffset.dy / cellSize).floor();
                  int col = (localOffset.dx / cellSize).floor();
                  if (row >= 0 && row < state.gridSize && col >= 0 && col < state.gridSize) {
                    _cubit.onCellDrag(row, col);
                  }
                },
                onPanEnd: (_) => _cubit.onDragEnd(),
                child: SizedBox(
                  width: cellSize * state.gridSize,
                  height: cellSize * state.gridSize,
                  child: Column(
                    children: List.generate(state.gridSize, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(state.gridSize, (col) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getCellColor(state, row, col),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: Text(
                                    state.grid[row][col],
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
    );
  }

  Widget _buildWordsToFind(FindWordGameState state) {
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
            const SizedBox(height: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: state.wordsToFind.map((word) {
                  bool isFound = state.foundWords.contains(word);
                  Color wordColor = state.wordColors[word] ?? Colors.grey;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFound ? wordColor.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFound ? wordColor : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      word,
                      style: AppTextStyles.keyboardKey.copyWith(
                        decoration: isFound ? TextDecoration.lineThrough : null,
                        color: isFound ? wordColor.withAlpha(100) : Colors.black87,
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
    );
  }

  Color _getCellColor(FindWordGameState state, int row, int col) {
    final pos = Position(row, col);
    if (state.selectedPositions.contains(pos)) {
      return Colors.blue.withOpacity(0.5);
    }
    for (String word in state.foundWords) {
      if (state.wordPositions[word]?.contains(pos) == true) {
        Color wordColor = state.wordColors[word] ?? Colors.green;
        return wordColor.withOpacity(0.4);
      }
    }
    return Colors.grey.shade200;
  }

  void _showCustomizeDialog(int currentGridSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempGridSize = currentGridSize;
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
                    Navigator.of(context).pop();
                    _cubit.initializeGame(gridSize: tempGridSize);
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
}

