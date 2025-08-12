# Simplified Flutter Word Game Architecture

## Simplified Architecture
#  Flutter Word Game Architecture

## Architecture

### Core Principles
- **Keep it simple**: Use Flutter's built-in widgets and state management
- **Local-first**: No complex sync or remote data sources needed initially
- **Progressive complexity**: Start minimal, add features as needed
- **Standard patterns**: Use well-established, simple patterns

## System Architecture (Updated for BLoC)

```
┌─────────────────────────────────────────────┐
│               Presentation                   │
│  ┌─────────────┐  ┌─────────────────────────┐│
│  │Game Screen  │  │Settings & Stats Screen  ││
│  │- Game Grid  │  │- Language Toggle        ││
│  │- Keyboard   │  │- Basic Stats            ││
│  │- Results    │  │- Sound Toggle           ││
│  └─────────────┘  └─────────────────────────┘│
├─────────────────────────────────────────────┤
│              State Management                │
│  ┌─────────────────────────────────────────┐ │
│  │               BLoC Layer                │ │
│  │   - GameBloc                           │ │
│  │   - SettingsBloc                       │ │
│  │   - StatsBloc                          │ │
│  └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────┤
│                Data Layer                    │
│  ┌─────────────┐  ┌─────────────────────────┐│
│  │Local Storage│  │      Services           ││
│  │- SQLite     │  │- Word Service           ││
│  │- SharedPrefs│  │- Audio Service          ││
│  │             │  │- Stats Service          ││
│  └─────────────┘  └─────────────────────────┘│
└─────────────────────────────────────────────┘
```

## Implementation Details

### 1. State Management - BLoC Pattern

#### Game Events
```dart
abstract class GameEvent extends Equatable {
  const GameEvent();
  
  @override
  List<Object> get props => [];
}

class GameStarted extends GameEvent {}

class LetterAdded extends GameEvent {
  final String letter;
  
  const LetterAdded(this.letter);
  
  @override
  List<Object> get props => [letter];
}

class LetterRemoved extends GameEvent {}

class GuessSubmitted extends GameEvent {}

class NewGameRequested extends GameEvent {}
```

#### Game States
```dart
abstract class GameState extends Equatable {
  const GameState();
  
  @override
  List<Object> get props => [];
}

class GameInitial extends GameState {}

class GameInProgress extends GameState {
  final List<List<String>> grid;
  final List<List<TileState>> tileStates;
  final int currentRow;
  final int currentCol;
  final String targetWord;
  final GameStatus status;
  final String? errorMessage;
  
  const GameInProgress({
    required this.grid,
    required this.tileStates,
    required this.currentRow,
    required this.currentCol,
    required this.targetWord,
    required this.status,
    this.errorMessage,
  });
  
  @override
  List<Object> get props => [
    grid,
    tileStates,
    currentRow,
    currentCol,
    targetWord,
    status,
    errorMessage ?? '',
  ];
  
  GameInProgress copyWith({
    List<List<String>>? grid,
    List<List<TileState>>? tileStates,
    int? currentRow,
    int? currentCol,
    String? targetWord,
    GameStatus? status,
    String? errorMessage,
  }) {
    return GameInProgress(
      grid: grid ?? this.grid,
      tileStates: tileStates ?? this.tileStates,
      currentRow: currentRow ?? this.currentRow,
      currentCol: currentCol ?? this.currentCol,
      targetWord: targetWord ?? this.targetWord,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

enum TileState { empty, correct, wrongPosition, notInWord }
enum GameStatus { playing, won, lost }
```

#### Game BLoC
```dart
class GameBloc extends Bloc<GameEvent, GameState> {
  final WordService wordService;
  final StatsService statsService;
  final AudioService audioService;
  
  GameBloc({
    required this.wordService,
    required this.statsService,
    required this.audioService,
  }) : super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<LetterAdded>(_onLetterAdded);
    on<LetterRemoved>(_onLetterRemoved);
    on<GuessSubmitted>(_onGuessSubmitted);
    on<NewGameRequested>(_onNewGameRequested);
  }
  
  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    final targetWord = wordService.getRandomWord();
    emit(GameInProgress(
      grid: List.generate(6, (_) => List.filled(5, '')),
      tileStates: List.generate(6, (_) => List.filled(5, TileState.empty)),
      currentRow: 0,
      currentCol: 0,
      targetWord: targetWord,
      status: GameStatus.playing,
    ));
  }
  
  void _onLetterAdded(LetterAdded event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final currentState = state as GameInProgress;
      
      if (currentState.currentCol < 5 && currentState.status == GameStatus.playing) {
        final newGrid = List<List<String>>.from(
          currentState.grid.map((row) => List<String>.from(row))
        );
        
        newGrid[currentState.currentRow][currentState.currentCol] = event.letter;
        
        audioService.playSound('key_tap');
        
        emit(currentState.copyWith(
          grid: newGrid,
          currentCol: currentState.currentCol + 1,
          errorMessage: null,
        ));
      }
    }
  }
  
  void _onLetterRemoved(LetterRemoved event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final currentState = state as GameInProgress;
      
      if (currentState.currentCol > 0) {
        final newGrid = List<List<String>>.from(
          currentState.grid.map((row) => List<String>.from(row))
        );
        
        newGrid[currentState.currentRow][currentState.currentCol - 1] = '';
        
        audioService.playSound('key_tap');
        
        emit(currentState.copyWith(
          grid: newGrid,
          currentCol: currentState.currentCol - 1,
          errorMessage: null,
        ));
      }
    }
  }
  
  void _onGuessSubmitted(GuessSubmitted event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final currentState = state as GameInProgress;
      
      if (currentState.currentCol == 5) {
        final guess = currentState.grid[currentState.currentRow].join();
        
        // Validate word
        if (!wordService.isValidWord(guess)) {
          audioService.playSound('error');
          emit(currentState.copyWith(errorMessage: 'Invalid word'));
          return;
        }
        
        // Update tile states
        final newTileStates = List<List<TileState>>.from(
          currentState.tileStates.map((row) => List<TileState>.from(row))
        );
        
        for (int i = 0; i < 5; i++) {
          if (guess[i] == currentState.targetWord[i]) {
            newTileStates[currentState.currentRow][i] = TileState.correct;
          } else if (currentState.targetWord.contains(guess[i])) {
            newTileStates[currentState.currentRow][i] = TileState.wrongPosition;
          } else {
            newTileStates[currentState.currentRow][i] = TileState.notInWord;
          }
        }
        
        // Check win/lose conditions
        GameStatus newStatus = currentState.status;
        if (guess == currentState.targetWord) {
          newStatus = GameStatus.won;
          statsService.recordWin(currentState.currentRow + 1);
          audioService.playSound('win');
        } else if (currentState.currentRow == 5) {
          newStatus = GameStatus.lost;
          statsService.recordLoss();
          audioService.playSound('lose');
        } else {
          audioService.playSound('guess_submitted');
        }
        
        emit(currentState.copyWith(
          tileStates: newTileStates,
          currentRow: currentState.currentRow + 1,
          currentCol: 0,
          status: newStatus,
          errorMessage: null,
        ));
      }
    }
  }
  
  void _onNewGameRequested(NewGameRequested event, Emitter<GameState> emit) {
    add(GameStarted());
  }
}
```

### 2. Simple Data Layer

#### Database Schema (SQLite)
```sql
-- Just 2 tables for the entire app
CREATE TABLE words (
  id INTEGER PRIMARY KEY,
  word TEXT NOT NULL,
  language TEXT NOT NULL CHECK(language IN ('shona', 'ndebele')),
  translation TEXT,
  definition TEXT
);

CREATE TABLE game_stats (
  id INTEGER PRIMARY KEY,
  date TEXT NOT NULL,
  language TEXT NOT NULL,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0
);
```

#### Word Service
```dart
class WordService {
  static late SQLiteDatabase _db;
  static String _currentLanguage = 'shona';
  
  static Future<void> initialize() async {
    _db = await openDatabase('words.db');
    await _loadInitialWords();
  }
  
  static String getRandomWord() {
    // Get random word from current language
    final words = _db.query('words', 
      where: 'language = ?', 
      whereArgs: [_currentLanguage]);
    
    if (words.isEmpty) return 'MAKUR'; // fallback
    
    final randomWord = words[Random().nextInt(words.length)];
    return randomWord['word'] as String;
  }
  
  static bool isValidWord(String word) {
    final result = _db.query('words',
      where: 'word = ? AND language = ?',
      whereArgs: [word.toUpperCase(), _currentLanguage]);
    
    return result.isNotEmpty;
  }
  
  static void setLanguage(String language) {
    _currentLanguage = language;
  }
}
```

### 3. App Styling & Theme System

#### Theme Configuration
```dart

// Custom typography for Shona and Ndebele text

```

#### Styled UI Components

```dart
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        wordService: context.read<WordService>(),
        statsService: context.read<StatsService>(),
        audioService: context.read<AudioService>(),
      )..add(GameStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              return Text(
                settingsState.currentLanguage == 'shona' 
                  ? 'Mutambo weMazwi' 
                  : 'Umdlalo wamazwi',
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              onPressed: () => _showStatsDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        body: BlocConsumer<GameBloc, GameState>(
          listener: (context, state) {
            if (state is GameInProgress && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GameInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is GameInProgress) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 3,
                    child: GameGrid(gameState: state),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == GameStatus.playing)
                    Expanded(
                      flex: 2,
                      child: VirtualKeyboard(gameState: state),
                    )
                  else
                    GameResultsWidget(gameState: state),
                  const SizedBox(height: 16),
                ],
              );
            }
            
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
  
  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StatsDialog(),
    );
  }
}

class GameGrid extends StatelessWidget {
  final GameInProgress gameState;
  
  const GameGrid({required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(6, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (colIndex) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LetterTile(
                    letter: gameState.grid[rowIndex][colIndex],
                    state: gameState.tileStates[rowIndex][colIndex],
                    isCurrentRow: rowIndex == gameState.currentRow,
                    isAnimated: rowIndex < gameState.currentRow ||
                        (rowIndex == gameState.currentRow && 
                         gameState.status != GameStatus.playing),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class LetterTile extends StatefulWidget {
  final String letter;
  final TileState state;
  final bool isCurrentRow;
  final bool isAnimated;
  
  const LetterTile({
    required this.letter,
    required this.state,
    this.isCurrentRow = false,
    this.isAnimated = false,
    super.key,
  });
  
  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flipAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
  }
  
  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !oldWidget.isAnimated) {
      _controller.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: widget.isCurrentRow && widget.letter.isNotEmpty
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.letter.toUpperCase(),
                  style: AppTextStyles.tileLetter.copyWith(
                    color: _getTextColor(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getBackgroundColor() {
    switch (widget.state) {
      case TileState.correct:
        return AppTheme.correctTile;
      case TileState.wrongPosition:
        return AppTheme.wrongPositionTile;
      case TileState.notInWord:
        return AppTheme.notInWordTile;
      default:
        return AppTheme.emptyTile;
    }
  }
  
  Color _getBorderColor() {
    if (widget.state != TileState.empty) {
      return _getBackgroundColor();
    }
    return widget.isCurrentRow && widget.letter.isNotEmpty
        ? AppTheme.primaryGold
        : AppTheme.emptyTileBorder;
  }
  
  Color _getTextColor() {
    return widget.state == TileState.empty 
        ? Colors.black 
        : Colors.white;
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class VirtualKeyboard extends StatelessWidget {
  final GameInProgress gameState;
  
  const VirtualKeyboard({required this.gameState, super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final layout = _getKeyboardLayout(settingsState.currentLanguage);
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: layout.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: KeyboardKey(
                        letter: key,
                        keyState: _getKeyState(key),
                        onPressed: () => _handleKeyPress(context, key),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  List<List<String>> _getKeyboardLayout(String language) {
    if (language == 'shona') {
      return [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['⏎', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
      ];
    } else {
      return [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['⏎', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
      ];
    }
  }
  
  KeyState _getKeyState(String key) {
    if (key == '⏎' || key == '⌫') return KeyState.normal;
    
    // Check if key has been used in previous guesses
    for (int row = 0; row < gameState.currentRow; row++) {
      for (int col = 0; col < 5; col++) {
        if (gameState.grid[row][col] == key) {
          switch (gameState.tileStates[row][col]) {
            case TileState.correct:
              return KeyState.correct;
            case TileState.wrongPosition:
              return KeyState.wrongPosition;
            case TileState.notInWord:
              return KeyState.notInWord;
            default:
              break;
          }
        }
      }
    }
    
    return KeyState.normal;
  }
  
  void _handleKeyPress(BuildContext context, String key) {
    final gameBloc = context.read<GameBloc>();
    
    if (key == '⌫') {
      gameBloc.add(LetterRemoved());
    } else if (key == '⏎') {
      gameBloc.add(GuessSubmitted());
    } else {
      gameBloc.add(LetterAdded(key));
    }
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  final KeyState keyState;
  final VoidCallback onPressed;
  
  const KeyboardKey({
    required this.letter,
    required this.keyState,
    required this.onPressed,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final isSpecialKey = letter == '⏎' || letter == '⌫';
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isSpecialKey ? 64 : 40,
        height: 56,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.keyboardKey.copyWith(
              color: _getTextColor(),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (keyState) {
      case KeyState.correct:
        return AppTheme.correctTile;
      case KeyState.wrongPosition:
        return AppTheme.wrongPositionTile;
      case KeyState.notInWord:
        return AppTheme.notInWordTile;
      default:
        return Colors.grey.shade200;
    }
  }
  
  Color _getBorderColor() {
    return keyState == KeyState.normal 
        ? Colors.grey.shade400 
        : _getBackgroundColor();
  }
  
  Color _getTextColor() {
    return keyState == KeyState.normal 
        ? Colors.black 
        : Colors.white;
  }
}

enum KeyState { normal, correct, wrongPosition
```

### 4. Simple Audio Service

```dart
class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _soundEnabled = true;
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
  }
  
  static Future<void> playSound(String soundType) async {
    if (!_soundEnabled) return;
    
    try {
      await _player.play(AssetSource('sounds/$soundType.wav'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
  
  static void toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }
}
```

### 5. Settings Management

```dart
class SettingsState extends ChangeNotifier {
  String _currentLanguage = 'shona';
  bool _soundEnabled = true;
  
  String get currentLanguage => _currentLanguage;
  bool get soundEnabled => _soundEnabled;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'shona';
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    notifyListeners();
  }
  
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    WordService.setLanguage(language);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }
  
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    AudioService.toggleSound();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    notifyListeners();
  }
}
```

lib/
├── main.dart
├── app/
│   ├── app.dart                    # Main app widget with theme
│   └── themes/
│       ├── app_theme.dart         # Theme configurations
│       └── app_text_styles.dart   # Typography styles
├── features/
│   ├── game/
│   │   ├── bloc/
│   │   │   ├── game_bloc.dart
│   │   │   ├── game_event.dart
│   │   │   └── game_state.dart
│   │   ├── screens/
│   │   │   └── game_screen.dart
│   │   └── widgets/
│   │       ├── game_grid.dart
│   │       ├── letter_tile.dart
│   │       ├── virtual_keyboard.dart
│   │       └── game_results.dart
│   ├── settings/
│   │   ├── bloc/
│   │   │   ├── settings_bloc.dart
│   │   │   ├── settings_event.dart
│   │   │   └── settings_state.dart
│   │   ├── screens/
│   │   │   └── settings_screen.dart
│   │   └── widgets/
│   │       └── settings_card.dart
│   └── stats/
│       ├── bloc/
│       │   ├── stats_bloc.dart
│       │   ├── stats_event.dart
│       │   └── stats_state.dart
│       └── widgets/
│           └── stats_dialog.dart
├── shared/
│   ├── models/
│   │   ├── word.dart
│   │   └── game_models.dart
│   ├── services/
│   │   ├── word_service.dart
│   │   ├── audio_service.dart
│   │   └── stats_service.dart
│   ├── widgets/
│   │   └── common_widgets.dart
│   └── utils/
│       ├── constants.dart
│       └── extensions.dart
└── assets/
    ├── audio/
    │   ├── sounds/
    │   └── pronunciations/
    ├── images/
    └── fonts/
```

## App Entry Point

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'shared/services/word_service.dart';
import 'shared/services/audio_service.dart';
import 'shared/services/stats_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await WordService.initialize();
  await AudioService.initialize();
  await StatsService.initialize();
  
  runApp(const WordGameApp());
}

// app/app.dart

```

## Additional UI Components & Animations

```dart
// Animated splash screen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _controller.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGold,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 60,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mutambo weMazwi',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shona & Ndebele Word Game',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Custom loading widget
class GameLoadingWidget extends StatelessWidget {
  const GameLoadingWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tichigadzira mutambo...',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
```

class GameResultsWidget extends StatelessWidget {
  final GameInProgress gameState;
  
  const GameResultsWidget({required this.gameState, super.key});
  
  @override
  Widget build(BuildContext context) {
    final isWon = gameState.status == GameStatus.won;
    
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isWon ? AppTheme.correctTile : AppTheme.notInWordTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWon ? '🎉 Makorokoto!' : '😔 Kana Ngomuso',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Shoko raiva: ${gameState.targetWord}',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isWon) ...[
            const SizedBox(height: 8),
            Text(
              'Makwidza mu${gameState.currentRow} attempts',
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<GameBloc>().add(NewGameRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isWon ? AppTheme.correctTile : AppTheme.notInWordTile,
            ),
            child: const Text('Mutambo Mutsva'),
          ),
        ],
      ),
    );
  }
}

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Zvibvumirano',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Mitambo',
                      value: state.gamesPlayed.toString(),
                    ),
                    _StatItem(
                      label: 'Kukunda %',
                      value: state.winPercentage.toStringAsFixed(0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Streak Yazvino',
                      value: state.currentStreak.toString(),
                    ),
                    _StatItem(
                      label: 'Streak Yakakura',
                      value: state.bestStreak.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vhara'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading1.copyWith(
            color: AppTheme.primaryGold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
```

#### Settings BLoC
```dart
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<LanguageChanged>(_onLanguageChanged);
    on<SoundToggled>(_onSoundToggled);
    on<ThemeChanged>(_onThemeChanged);
  }
  
  void _onSettingsLoaded(SettingsLoaded event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      currentLanguage: prefs.getString('language') ?? 'shona',
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      isDarkMode: prefs.getBool('dark_mode') ?? false,
    ));
  }
  
  void _onLanguageChanged(LanguageChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', event.language);
    emit(state.copyWith(currentLanguage: event.language));
  }
  
  void _onSoundToggled(SoundToggled event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', !state.soundEnabled);
    emit(state.copyWith(soundEnabled: !state.soundEnabled));
  }
  
  void _onThemeChanged(ThemeChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', event.isDark);
    emit(state.copyWith(isDarkMode: event.isDark));
  }
}

class SettingsState extends Equatable {
  final String currentLanguage;
  final bool soundEnabled;
  final bool isDarkMode;
  
  const SettingsState({
    this.currentLanguage = 'shona',
    this.soundEnabled = true,
    this.isDarkMode = false,
  });
  
  SettingsState copyWith({
    String? currentLanguage,
    bool? soundEnabled,
    bool? isDarkMode,
  }) {
    return SettingsState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
  
  @override
  List<Object> get props => [currentLanguage, soundEnabled, isDarkMode];
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magadzirirwo'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsCard(
                title: 'Mutauro',
                children: [
                  RadioListTile<String>(
                    title: const Text('ChiShona'),
                    value: 'shona',
                    groupValue: state.currentLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(LanguageChanged(value));
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('IsiNdebele'),
                    value: 'ndebele',
                    groupValue: state.currentLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(LanguageChanged(value));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Mazwi',
                children: [
                  SwitchListTile(
                    title: const Text('Ruzha'),
                    subtitle: const Text('Batidza mazwi nemisindo'),
                    value: state.soundEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(SoundToggled());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Chitarisiko',
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Shandisa ruvara rwakasviba'),
                    value: state.isDarkMode,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ThemeChanged(value));
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _SettingsCard({required this.title, required this.children});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: AppTextStyles.heading2,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Data Storage
  sqflite: ^2.3.0
  shared_preferences: ^2.2.0
  
  # Audio
  audioplayers: ^5.0.0
  
  # UI Enhancements
  lottie: ^2.6.0            # For animations
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  bloc_test: ^9.1.4         # For testing BLoCs
```

## Key Improvements Over Previous Plan (Updated)

1. **Removed Flame Engine**: Using standard Flutter widgets with beautiful animations - no need for game engine
2. **Simplified BLoC Architecture**: Three focused BLoCs (Game, Settings, Stats) instead of complex layered architecture
3. **Cultural Design Elements**: Zimbabwean-inspired color palette (gold, red, green) with thoughtful typography
4. **Minimal Database**: 2 tables instead of 7+ complex tables
5. **Standard Audio**: Basic AudioPlayer with smart caching instead of complex audio management
6. **Beautiful Animations**: Tile flips, keyboard feedback, and smooth transitions using Flutter's animation system
7. **No Repository Pattern**: Direct service classes - much simpler
8. **Responsive Design**: Proper spacing, touch targets, and visual hierarchy
9. **Cultural Localization**: Proper Shona/Ndebele text and culturally appropriate messaging
10. **Progressive Enhancement**: Clean architecture that allows for easy feature additions

## Responsive Design Considerations

```dart
// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Responsive helper widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= Breakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= Breakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Adaptive game grid that works on different screen sizes
class AdaptiveGameGrid extends StatelessWidget {
  final GameInProgress gameState;
  
  const AdaptiveGameGrid({required this.gameState, super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileGrid(),
      tablet: _buildTabletGrid(),
      desktop: _buildDesktopGrid(),
    );
  }
  
  Widget _buildMobileGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildGrid(tileSize: 56),
    );
  }
  
  Widget _buildTabletGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: _buildGrid(tileSize: 72),
    );
  }
  
  Widget _buildDesktopGrid() {
    return Center(
      child: SizedBox(
        width: 500,
        child: _buildGrid(tileSize: 80),
      ),
    );
  }
  
  Widget _buildGrid({required double tileSize}) {
    return Column(
      children: List.generate(6, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (colIndex) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: LetterTile(
                    letter: gameState.grid[rowIndex][colIndex],
                    state: gameState.tileStates[rowIndex][colIndex],
                    isCurrentRow: rowIndex == gameState.currentRow,
                    isAnimated: rowIndex < gameState.currentRow ||
                        (rowIndex == gameState.currentRow && 
                         gameState.status != GameStatus.playing),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
```

## Development Phases

### Phase 1: MVP (2-3 weeks)
- Basic game mechanics (guessing, tile states)
- Word validation
- Simple UI with Flutter widgets
- Basic audio feedback
- Language switching (Shona/Ndebele)

### Phase 2: Polish (1-2 weeks)
- Better animations and transitions
- Statistics tracking
- Settings screen
- Improved visual design

### Phase 3: Enhanced Features (as needed)
- Daily challenges
- Word definitions
- Achievement system
- Audio pronunciations
