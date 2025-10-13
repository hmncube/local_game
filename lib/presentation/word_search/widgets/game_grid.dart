import 'dart:math';

import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/presentation/word_search/find_word_game_cubit.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

class GameGrid extends StatefulWidget {
  final FindWordGameState state;
  final FindWordGameCubit cubit;
  final Position? hintPosition;
  const GameGrid({
    super.key,
    required this.state,
    required this.cubit,
    required this.hintPosition,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.state.grid.isEmpty) {
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
              double cellSize =
                  min(gridWidth, gridHeight) / widget.state.gridSize;

              return GestureDetector(
                onPanStart: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(
                    details.globalPosition,
                  );
                  int row = (localOffset.dy / cellSize).floor();
                  int col = (localOffset.dx / cellSize).floor();
                  if (row >= 0 &&
                      row < widget.state.gridSize &&
                      col >= 0 &&
                      col < widget.state.gridSize) {
                    widget.cubit.onCellTap(row, col);
                  }
                },
                onPanUpdate: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(
                    details.globalPosition,
                  );
                  int row = (localOffset.dy / cellSize).floor();
                  int col = (localOffset.dx / cellSize).floor();
                  if (row >= 0 &&
                      row < widget.state.gridSize &&
                      col >= 0 &&
                      col < widget.state.gridSize) {
                    widget.cubit.onCellDrag(row, col);
                  }
                },
                onPanEnd: (_) => widget.cubit.onDragEnd(),
                child: SizedBox(
                  width: cellSize * widget.state.gridSize,
                  height: cellSize * widget.state.gridSize,
                  child: Column(
                    children: List.generate(widget.state.gridSize, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(widget.state.gridSize, (col) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getCellColor(widget.state, row, col),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.state.grid[row][col],
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

  Color _getCellColor(FindWordGameState state, int row, int col) {
    final pos = Position(row, col);
    if (state.selectedPositions.contains(pos)) {
      return Colors.blue.withAlpha(128);
    }
    for (String word in state.foundWords) {
      if (state.wordPositions[word]?.contains(pos) == true) {
        Color wordColor = state.wordColors[word] ?? Colors.green;
        return wordColor.withAlpha(128);
      }
    }

    if (state.hintPosition != null &&
        state.hintPosition?.col == col &&
        state.hintPosition?.row == row) {
      return Colors.yellow.withAlpha(128);
    }

    return Colors.grey.shade200;
  }
}
