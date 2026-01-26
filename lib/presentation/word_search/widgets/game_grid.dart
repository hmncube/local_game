import 'dart:math';

import 'package:flutter/material.dart';
import 'package:local_game/presentation/word_search/find_word_game_cubit.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class GameGrid extends StatefulWidget {
  final FindWordGameState state;
  final FindWordGameCubit cubit;
  final Position? hintPosition;
  final Color darkBorderColor;
  final Color accentOrange;

  const GameGrid({
    super.key,
    required this.state,
    required this.cubit,
    required this.hintPosition,
    required this.darkBorderColor,
    required this.accentOrange,
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
      flex: 3,
      child: Center(
        child: NeubrutalismContainer(
          borderRadius: 20,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(8),
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
                            final cellColor = _getCellColor(
                              widget.state,
                              row,
                              col,
                            );
                            final isSelected = widget.state.selectedPositions
                                .contains(Position(row, col));

                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cellColor,
                                  border: Border.all(
                                    color: widget.darkBorderColor.withOpacity(
                                      0.1,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.state.grid[row][col],
                                    style: TextStyle(
                                      fontSize: cellSize * 0.45,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : widget.darkBorderColor,
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
      return widget.accentOrange;
    }
    for (String word in state.foundWords) {
      if (state.wordPositions[word]?.contains(pos) == true) {
        Color wordColor = state.wordColors[word] ?? Colors.green;
        return wordColor.withOpacity(0.4);
      }
    }

    if (state.hintPosition != null &&
        state.hintPosition?.col == col &&
        state.hintPosition?.row == row) {
      return Colors.yellow.withOpacity(0.6);
    }

    return Colors.transparent;
  }
}
