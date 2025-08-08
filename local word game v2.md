# Simplified Flutter Word Game Architecture

## Issues with Previous Plan

The previous architecture plan suffers from significant overengineering:

### Major Overengineering Issues:
- **Flame Game Engine**: Completely unnecessary for a word guessing game. Flame is for complex 2D games with physics, animations, and real-time interactions. A simple word game needs basic UI widgets.
- **Complex BLoC Architecture**: Three separate BLoCs (GamePlay, Progress, Settings) when simple state management would suffice.
- **Repository Pattern Overkill**: Abstract interfaces and multiple data sources for what should be local-only data.
- **Overcomplicated Database**: 7+ tables for what could be 2-3 simple tables.
- **Custom Audio Engine**: Building complex audio caching when Flutter's basic audio players are sufficient.
- **Memory Management System**: Custom asset managers and LRU caches for a simple word game.
- **Encryption**: Unnecessary security complexity for local game progress.
- **Performance Monitoring**: Firebase Performance for a simple offline game is overkill.

## Simplified Architecture

### Core Principles
- **Keep it simple**: Use Flutter's built-in widgets and state management
- **Local-first**: No complex sync or remote data sources needed initially
- **Progressive complexity**: Start minimal, add features as needed
- **Standard patterns**: Use well-established, simple patterns

## System Architecture

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
│  │          Provider/Riverpod             │ │
│  │   - GameStateNotifier                 │ │
│  │   - SettingsNotifier                  │ │
│  └─────────────────────────────────────────┘ │
├─────────────────────────────────────────────┤
│                Data Layer                    │
│  ┌─────────────┐  ┌─────────────────────────┐│
│  │Local Storage│  │      Services           ││
│  │- SQLite     │  │- Word Service           ││
│  │- SharedPrefs│  │- Audio Service          ││
│  └─────────────┘  └─────────────────────────┘│
└─────────────────────────────────────────────┘
```

## Implementation Details

### 1. State Management - Simple Provider Pattern

```dart
class GameState extends ChangeNotifier {
  List<List<String>> _grid = List.generate(6, (_) => List.filled(5, ''));
  List<List<TileState>> _tileStates = List.generate(6, (_) => List.filled(5, TileState.empty));
  int _currentRow = 0;
  int _currentCol = 0;
  String _targetWord = '';
  GameStatus _status = GameStatus.playing;
  
  // Getters
  List<List<String>> get grid => _grid;
  List<List<TileState>> get tileStates => _tileStates;
  int get currentRow => _currentRow;
  GameStatus get status => _status;
  
  void startNewGame() {
    _targetWord = WordService.getRandomWord();
    _grid = List.generate(6, (_) => List.filled(5, ''));
    _tileStates = List.generate(6, (_) => List.filled(5, TileState.empty));
    _currentRow = 0;
    _currentCol = 0;
    _status = GameStatus.playing;
    notifyListeners();
  }
  
  void addLetter(String letter) {
    if (_currentCol < 5 && _status == GameStatus.playing) {
      _grid[_currentRow][_currentCol] = letter;
      _currentCol++;
      notifyListeners();
    }
  }
  
  void removeLetter() {
    if (_currentCol > 0) {
      _currentCol--;
      _grid[_currentRow][_currentCol] = '';
      notifyListeners();
    }
  }
  
  void submitGuess() {
    if (_currentCol == 5) {
      String guess = _grid[_currentRow].join();
      
      // Check if valid word
      if (!WordService.isValidWord(guess)) {
        // Show error - invalid word
        return;
      }
      
      // Update tile states
      for (int i = 0; i < 5; i++) {
        if (guess[i] == _targetWord[i]) {
          _tileStates[_currentRow][i] = TileState.correct;
        } else if (_targetWord.contains(guess[i])) {
          _tileStates[_currentRow][i] = TileState.wrongPosition;
        } else {
          _tileStates[_currentRow][i] = TileState.notInWord;
        }
      }
      
      // Check win/lose conditions
      if (guess == _targetWord) {
        _status = GameStatus.won;
        StatsService.recordWin(_currentRow + 1);
      } else if (_currentRow == 5) {
        _status = GameStatus.lost;
        StatsService.recordLoss();
      }
      
      _currentRow++;
      _currentCol = 0;
      notifyListeners();
    }
  }
}

enum TileState { empty, correct, wrongPosition, notInWord }
enum GameStatus { playing, won, lost }
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

### 3. UI Implementation - Standard Flutter Widgets

```dart
class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<SettingsState>().currentLanguage == 'shona' 
          ? 'Mutambo weMazwi' : 'Umdlalo wamazwi'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, 
              MaterialPageRoute(builder: (_) => SettingsScreen())),
          ),
        ],
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, _) {
          return Column(
            children: [
              Expanded(child: GameGrid()),
              if (gameState.status == GameStatus.playing)
                VirtualKeyboard(),
              if (gameState.status != GameStatus.playing)
                GameResultsWidget(),
            ],
          );
        },
      ),
    );
  }
}

class GameGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 30, // 6 rows × 5 columns
          itemBuilder: (context, index) {
            final row = index ~/ 5;
            final col = index % 5;
            
            return LetterTile(
              letter: gameState.grid[row][col],
              state: gameState.tileStates[row][col],
            );
          },
        );
      },
    );
  }
}

class LetterTile extends StatelessWidget {
  final String letter;
  final TileState state;
  
  const LetterTile({required this.letter, required this.state});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (state) {
      case TileState.correct: return Colors.green;
      case TileState.wrongPosition: return Colors.orange;
      case TileState.notInWord: return Colors.grey;
      default: return Colors.white;
    }
  }
  
  Color _getTextColor() {
    return state == TileState.empty ? Colors.black : Colors.white;
  }
}
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

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── game_state.dart
│   └── word.dart
├── screens/
│   ├── game_screen.dart
│   ├── settings_screen.dart
│   └── stats_screen.dart
├── widgets/
│   ├── game_grid.dart
│   ├── letter_tile.dart
│   ├── virtual_keyboard.dart
│   └── results_widget.dart
├── services/
│   ├── word_service.dart
│   ├── audio_service.dart
│   └── stats_service.dart
└── providers/
    ├── game_provider.dart
    └── settings_provider.dart
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5          # Simple state management
  sqflite: ^2.3.0          # Local database
  shared_preferences: ^2.2.0 # Simple settings storage
  audioplayers: ^5.0.0     # Basic audio playback
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Key Improvements Over Previous Plan

1. **Removed Flame Engine**: Using standard Flutter widgets - no need for game engine
2. **Simplified State Management**: Single Provider instead of multiple BLoCs
3. **Minimal Database**: 2 tables instead of 7+ complex tables
4. **Standard Audio**: Basic AudioPlayer instead of complex audio management
5. **No Repository Pattern**: Direct service classes - much simpler
6. **No Complex Security**: SharedPreferences for settings, no encryption needed
7. **No Performance Monitoring**: Standard Flutter performance is sufficient
8. **Removed Memory Management**: Flutter handles widget lifecycle automatically
9. **Simplified Localization**: Basic string switching instead of complex i18n system

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

This simplified architecture will be much faster to implement, easier to maintain, and perfectly adequate for a word guessing game. The previous plan was solving problems that don't exist for this type of application.