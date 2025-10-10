import 'package:flutter/material.dart';
import 'dart:math';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late CrosswordPuzzle puzzle;
  Map<String, String> userAnswers = {};
  String? selectedClueId;

  @override
  void initState() {
    super.initState();
    puzzle = CrosswordGenerator.generate();
  }

  void _randomize() {
    setState(() {
      puzzle = CrosswordGenerator.generate();
      userAnswers.clear();
      selectedClueId = null;
    });
  }

  void _checkAnswers() {
    int correct = 0;
    int total = puzzle.clues.length;

    for (var clue in puzzle.clues) {
      String userAnswer = userAnswers[clue.id]?.toUpperCase() ?? '';
      if (userAnswer == clue.answer) {
        correct++;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Results'),
        content: Text('You got $correct out of $total correct!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Puzzle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _randomize,
            tooltip: 'Randomize',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkAnswers,
            tooltip: 'Check Answers',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          
          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildGrid(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildCluesList(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildGrid(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildCluesList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: puzzle.size,
                childAspectRatio: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: puzzle.size * puzzle.size,
              itemBuilder: (context, index) {
                int row = index ~/ puzzle.size;
                int col = index % puzzle.size;
                return _buildCell(row, col);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    CellData? cellData = puzzle.getCellData(row, col);
    
    if (cellData == null) {
      return Container(color: Colors.black);
    }

    bool isSelected = selectedClueId != null && 
                     cellData.clueIds.contains(selectedClueId);

    return GestureDetector(
      onTap: () {
        if (cellData.clueIds.isNotEmpty) {
          setState(() {
            selectedClueId = cellData.clueIds.first;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Stack(
          children: [
            if (cellData.number != null)
              Positioned(
                top: 2,
                left: 2,
                child: Text(
                  cellData.number.toString(),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            Center(
              child: Text(
                cellData.letter.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCluesList() {
    List<Clue> acrossClues = puzzle.clues.where((c) => c.direction == Direction.across).toList();
    List<Clue> downClues = puzzle.clues.where((c) => c.direction == Direction.down).toList();

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ACROSS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...acrossClues.map((clue) => _buildClueItem(clue)),
          const SizedBox(height: 16),
          const Text(
            'DOWN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...downClues.map((clue) => _buildClueItem(clue)),
        ],
      ),
    );
  }

  Widget _buildClueItem(Clue clue) {
    bool isSelected = selectedClueId == clue.id;
    
    return Card(
      color: isSelected ? Colors.blue[50] : null,
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${clue.number}. ${clue.clue}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Your answer (${clue.answer.length} letters)',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              maxLength: clue.answer.length,
              onChanged: (value) {
                setState(() {
                  userAnswers[clue.id] = value;
                });
              },
              onTap: () {
                setState(() {
                  selectedClueId = clue.id;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum Direction { across, down }

class Clue {
  final String id;
  final int number;
  final String clue;
  final String answer;
  final Direction direction;
  final int row;
  final int col;

  Clue({
    required this.id,
    required this.number,
    required this.clue,
    required this.answer,
    required this.direction,
    required this.row,
    required this.col,
  });
}

class CellData {
  final String letter;
  final int? number;
  final List<String> clueIds;

  CellData({required this.letter, this.number, required this.clueIds});
}

class CrosswordPuzzle {
  final int size;
  final List<Clue> clues;
  final List<List<String?>> grid;

  CrosswordPuzzle({required this.size, required this.clues, required this.grid});

  CellData? getCellData(int row, int col) {
    if (grid[row][col] == null) return null;

    List<String> cellClueIds = [];
    int? cellNumber;

    for (var clue in clues) {
      if (clue.direction == Direction.across) {
        if (clue.row == row && col >= clue.col && col < clue.col + clue.answer.length) {
          cellClueIds.add(clue.id);
          if (col == clue.col) cellNumber = clue.number;
        }
      } else {
        if (clue.col == col && row >= clue.row && row < clue.row + clue.answer.length) {
          cellClueIds.add(clue.id);
          if (row == clue.row) cellNumber = clue.number;
        }
      }
    }

    return CellData(
      letter: grid[row][col]!,
      number: cellNumber,
      clueIds: cellClueIds,
    );
  }
}

class CrosswordGenerator {
  static final List<Map<String, String>> wordBank = [
    {'word': 'FLUTTER', 'clue': 'Google\'s UI toolkit'},
    {'word': 'DART', 'clue': 'Programming language for Flutter'},
    {'word': 'WIDGET', 'clue': 'Basic building block in Flutter'},
    {'word': 'STATE', 'clue': 'Mutable data in StatefulWidget'},
    {'word': 'BUILD', 'clue': 'Method that returns UI'},
    {'word': 'ASYNC', 'clue': 'Asynchronous programming keyword'},
    {'word': 'STREAM', 'clue': 'Sequence of async events'},
    {'word': 'FUTURE', 'clue': 'Result of async operation'},
    {'word': 'MATERIAL', 'clue': 'Design system by Google'},
    {'word': 'SCAFFOLD', 'clue': 'Basic visual layout structure'},
  ];

  static CrosswordPuzzle generate() {
    Random rand = Random();
    int size = 10;
    List<List<String?>> grid = List.generate(size, (_) => List.filled(size, null));
    List<Clue> clues = [];
    
    // Shuffle and select words
    List<Map<String, String>> selectedWords = List.from(wordBank)..shuffle(rand);
    selectedWords = selectedWords.take(6 + rand.nextInt(3)).toList();

    int clueNumber = 1;

    for (int i = 0; i < selectedWords.length; i++) {
      String word = selectedWords[i]['word']!;
      String clueText = selectedWords[i]['clue']!;
      Direction dir = i % 2 == 0 ? Direction.across : Direction.down;
      
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 50) {
        int row = rand.nextInt(size - (dir == Direction.down ? word.length : 0));
        int col = rand.nextInt(size - (dir == Direction.across ? word.length : 0));
        
        if (_canPlaceWord(grid, word, row, col, dir)) {
          _placeWord(grid, word, row, col, dir);
          clues.add(Clue(
            id: 'clue_$i',
            number: clueNumber++,
            clue: clueText,
            answer: word,
            direction: dir,
            row: row,
            col: col,
          ));
          placed = true;
        }
        attempts++;
      }
    }

    return CrosswordPuzzle(size: size, clues: clues, grid: grid);
  }

  static bool _canPlaceWord(List<List<String?>> grid, String word, int row, int col, Direction dir) {
    for (int i = 0; i < word.length; i++) {
      int r = dir == Direction.across ? row : row + i;
      int c = dir == Direction.across ? col + i : col;
      
      if (grid[r][c] != null && grid[r][c] != word[i]) {
        return false;
      }
    }
    return true;
  }

  static void _placeWord(List<List<String?>> grid, String word, int row, int col, Direction dir) {
    for (int i = 0; i < word.length; i++) {
      int r = dir == Direction.across ? row : row + i;
      int c = dir == Direction.across ? col + i : col;
      grid[r][c] = word[i];
    }
  }
}