# Flutter Word Game Technical Architecture

## Architecture Overview

This document outlines the technical architecture for the Shona and Ndebele word game Flutter application, designed for scalability, maintainability, and optimal performance across multiple platforms.

## System Architecture Pattern

### Clean Architecture Implementation

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Game Screens  │  │  Settings UI    │  │  Profile    │  │
│  │   - GameBoard   │  │  - Language     │  │  - Stats    │  │
│  │   - Keyboard    │  │  - Audio        │  │  - Badges   │  │
│  │   - Results     │  │  - Theme        │  │  - Progress │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Game BLoCs    │  │  Data BLoCs     │  │  Audio      │  │
│  │   - GamePlay    │  │  - Vocabulary   │  │  - Player   │  │
│  │   - Progress    │  │  - User Stats   │  │  - Manager  │  │
│  │   - Settings    │  │  - Achievements │  │             │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     Data Access Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │  Repositories   │  │  Local Storage  │  │  Services   │  │
│  │  - Word Repo    │  │  - SQLite DB    │  │  - Audio    │  │
│  │  - User Repo    │  │  - SharedPrefs  │  │  - Analytics│  │
│  │  - Audio Repo   │  │  - File System  │  │  - Sync     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Core Components Architecture

### 1. State Management with BLoC Pattern

#### Game State Management
```dart
// Core game state structure
abstract class GameState {
  const GameState();
}

class GameInitial extends GameState {}
class GameInProgress extends GameState {
  final List<WordGuess> guesses;
  final String targetWord;
  final int currentAttempt;
  final GameStatus status;
}

class GameCompleted extends GameState {
  final bool isWon;
  final int attempts;
  final String targetWord;
  final int score;
}

// Game BLoC implementation
class GameBloc extends Bloc<GameEvent, GameState> {
  final WordRepository wordRepository;
  final UserRepository userRepository;
  final AudioService audioService;
  
  GameBloc({
    required this.wordRepository,
    required this.userRepository,
    required this.audioService,
  }) : super(GameInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<SubmitGuess>(_onSubmitGuess);
    on<UseHint>(_onUseHint);
  }
}
```

#### Vocabulary Management BLoC
```dart
class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final WordRepository wordRepository;
  
  VocabularyBloc({required this.wordRepository}) : super(VocabularyInitial()) {
    on<LoadVocabulary>(_onLoadVocabulary);
    on<SearchWords>(_onSearchWords);
    on<AddCustomWord>(_onAddCustomWord);
    on<SyncVocabulary>(_onSyncVocabulary);
  }
}
```

### 2. Data Layer Architecture

#### Repository Pattern Implementation
```dart
// Abstract word repository interface
abstract class WordRepository {
  Future<Word> getDailyWord(DateTime date);
  Future<List<Word>> getWordsByCategory(String category);
  Future<List<Word>> getWordsByDifficulty(DifficultyLevel level);
  Future<bool> validateWord(String word);
  Future<void> cacheWords(List<Word> words);
  Stream<List<Word>> watchUserProgress();
}

// Concrete implementation
class WordRepositoryImpl implements WordRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final CacheManager cacheManager;
  
  WordRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.cacheManager,
  });
  
  @override
  Future<Word> getDailyWord(DateTime date) async {
    try {
      // Try local cache first
      final cachedWord = await localDataSource.getDailyWord(date);
      if (cachedWord != null) return cachedWord;
      
      // Fallback to remote source
      final remoteWord = await remoteDataSource.getDailyWord(date);
      await localDataSource.saveDailyWord(remoteWord);
      return remoteWord;
    } catch (e) {
      throw WordRepositoryException('Failed to fetch daily word: $e');
    }
  }
}
```

#### Database Schema Design
```sql
-- SQLite database schema for local storage

-- Core vocabulary table
CREATE TABLE words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word TEXT NOT NULL UNIQUE,
  language TEXT NOT NULL CHECK(language IN ('shona', 'ndebele')),
  translation TEXT NOT NULL,
  definition TEXT,
  pronunciation_url TEXT,
  category TEXT,
  difficulty_level INTEGER CHECK(difficulty_level BETWEEN 1 AND 5),
  cultural_context TEXT,
  usage_example TEXT,
  audio_file_path TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User progress tracking
CREATE TABLE user_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER REFERENCES words(id),
  user_id TEXT NOT NULL,
  first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  times_seen INTEGER DEFAULT 1,
  times_correct INTEGER DEFAULT 0,
  mastery_level REAL DEFAULT 0.0,
  is_learned BOOLEAN DEFAULT FALSE
);

-- Game sessions
CREATE TABLE game_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL UNIQUE,
  user_id TEXT NOT NULL,
  game_mode TEXT NOT NULL,
  target_word_id INTEGER REFERENCES words(id),
  start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_time TIMESTAMP,
  attempts INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  is_won BOOLEAN DEFAULT FALSE,
  score INTEGER DEFAULT 0,
  hints_used INTEGER DEFAULT 0,
  time_taken INTEGER -- in seconds
);

-- Daily challenges
CREATE TABLE daily_challenges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  challenge_date DATE NOT NULL UNIQUE,
  word_id INTEGER REFERENCES words(id),
  language TEXT NOT NULL,
  difficulty_level INTEGER,
  bonus_points INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);

-- User achievements
CREATE TABLE achievements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  achievement_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_path TEXT,
  points_required INTEGER,
  category TEXT
);

-- User achievement progress
CREATE TABLE user_achievements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  achievement_id TEXT REFERENCES achievements(achievement_id),
  progress INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP,
  UNIQUE(user_id, achievement_id)
);

-- Indexes for performance
CREATE INDEX idx_words_language ON words(language);
CREATE INDEX idx_words_category ON words(category);
CREATE INDEX idx_words_difficulty ON words(difficulty_level);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_game_sessions_user_id ON game_sessions(user_id);
CREATE INDEX idx_daily_challenges_date ON daily_challenges(challenge_date);
```

### 3. Game Engine Integration

#### Flame Engine Architecture
```dart
// Game world component
class WordGameWorld extends World with HasCollisionDetection {
  late final GameBoard gameBoard;
  late final VirtualKeyboard keyboard;
  late final UIOverlay uiOverlay;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize game components
    gameBoard = GameBoard();
    keyboard = VirtualKeyboard();
    uiOverlay = UIOverlay();
    
    // Add components to world
    add(gameBoard);
    add(keyboard);
    add(uiOverlay);
  }
}

// Game component for letter tiles
class LetterTile extends PositionComponent with HasGameRef<WordGameWorld> {
  final String letter;
  final TileState state;
  late final RectangleComponent background;
  late final TextComponent text;
  
  LetterTile({
    required this.letter,
    this.state = TileState.empty,
    required Vector2 position,
  }) : super(position: position, size: Vector2(60, 60));
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = _getBackgroundColor(),
    );
    
    // Create text
    text = TextComponent(
      text: letter.toUpperCase(),
      textRenderer: TextPaint(
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(background);
    add(text);
  }
  
  void updateState(TileState newState) {
    state = newState;
    background.paint.color = _getBackgroundColor();
    text.textRenderer = TextPaint(
      style: TextStyle(
        color: _getTextColor(),
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
```

### 4. Audio System Architecture

#### Audio Service Implementation
```dart
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  late final AudioPlayer _sfxPlayer;
  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _pronunciationPlayer;
  
  final Map<String, String> _cachedAudio = {};
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  Future<void> initialize() async {
    _sfxPlayer = AudioPlayer();
    _musicPlayer = AudioPlayer();
    _pronunciationPlayer = AudioPlayer();
    
    // Load user preferences
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
  }
  
  Future<void> playPronunciation(String word, String language) async {
    if (!_soundEnabled) return;
    
    try {
      final audioPath = await _getAudioPath(word, language);
      if (audioPath != null) {
        await _pronunciationPlayer.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      debugPrint('Error playing pronunciation: $e');
    }
  }
  
  Future<void> playSoundEffect(SoundEffect effect) async {
    if (!_soundEnabled) return;
    
    final soundPath = _getSoundEffectPath(effect);
    await _sfxPlayer.play(AssetSource(soundPath));
  }
  
  Future<String?> _getAudioPath(String word, String language) async {
    final cacheKey = '${language}_$word';
    
    if (_cachedAudio.containsKey(cacheKey)) {
      return _cachedAudio[cacheKey];
    }
    
    // Try to find local audio file
    final localPath = await _findLocalAudio(word, language);
    if (localPath != null) {
      _cachedAudio[cacheKey] = localPath;
      return localPath;
    }
    
    // Generate audio path based on word and language
    return null;
  }
}

enum SoundEffect {
  letterType,
  correctGuess,
  incorrectGuess,
  gameWin,
  gameLose,
  buttonTap,
  achievement,
}
```

### 5. Localization Architecture

#### Language Service Implementation
```dart
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();
  
  Language _currentLanguage = Language.shona;
  final Map<String, Map<String, String>> _translations = {};
  
  Language get currentLanguage => _currentLanguage;
  
  Future<void> initialize() async {
    await _loadTranslations();
    await _loadUserLanguagePreference();
  }
  
  Future<void> setLanguage(Language language) async {
    _currentLanguage = language;
    await _saveLanguagePreference(language);
    
    // Notify listeners of language change
    _languageController.add(language);
  }
  
  String translate(String key, {Map<String, String>? params}) {
    final languageCode = _currentLanguage.code;
    final translation = _translations[languageCode]?[key] ?? key;
    
    if (params != null) {
      return _interpolateParams(translation, params);
    }
    
    return translation;
  }
  
  Future<void> _loadTranslations() async {
    // Load translation files for each language
    for (final language in Language.values) {
      final translationPath = 'assets/translations/${language.code}.json';
      final jsonString = await rootBundle.loadString(translationPath);
      final translations = json.decode(jsonString) as Map<String, dynamic>;
      
      _translations[language.code] = translations.cast<String, String>();
    }
  }
}

enum Language {
  shona('sn', 'Shona', 'ChiShona'),
  ndebele('nd', 'Ndebele', 'IsiNdebele'),
  english('en', 'English', 'English');
  
  const Language(this.code, this.name, this.nativeName);
  
  final String code;
  final String name;
  final String nativeName;
}
```

### 6. Performance Optimization

#### Memory Management
```dart
class GameAssetManager {
  static final GameAssetManager _instance = GameAssetManager._internal();
  factory GameAssetManager() => _instance;
  GameAssetManager._internal();
  
  final Map<String, Image> _imageCache = {};
  final Map<String, AudioPlayer> _audioCache = {};
  final Queue<String> _recentlyUsed = Queue<String>();
  
  static const int maxCacheSize = 50;
  
  Future<Image> loadImage(String path) async {
    if (_imageCache.containsKey(path)) {
      _updateRecentlyUsed(path);
      return _imageCache[path]!;
    }
    
    final image = await _loadImageFromAssets(path);
    _cacheImage(path, image);
    return image;
  }
  
  void _cacheImage(String path, Image image) {
    if (_imageCache.length >= maxCacheSize) {
      _evictLeastRecentlyUsed();
    }
    
    _imageCache[path] = image;
    _updateRecentlyUsed(path);
  }
  
  void _evictLeastRecentlyUsed() {
    if (_recentlyUsed.isNotEmpty) {
      final oldestPath = _recentlyUsed.removeFirst();
      _imageCache.remove(oldestPath)?.dispose();
    }
  }
  
  void dispose() {
    _imageCache.values.forEach((image) => image.dispose());
    _imageCache.clear();
    _audioCache.values.forEach((player) => player.dispose());
    _audioCache.clear();
    _recentlyUsed.clear();
  }
}
```

#### Widget Optimization
```dart
class OptimizedGameBoard extends StatelessWidget {
  const OptimizedGameBoard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        // Only rebuild when game state actually changes
        return previous.runtimeType != current.runtimeType ||
               (current is GameInProgress && 
                previous is GameInProgress && 
                current.guesses != previous.guesses);
      },
      builder: (context, state) {
        if (state is GameInProgress) {
          return _buildGameGrid(state);
        }
        return const GameLoadingWidget();
      },
    );
  }
  
  Widget _buildGameGrid(GameInProgress state) {
    return ListView.builder(
      itemCount: 6, // Maximum attempts
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return const OptimizedWordRow(); // Const constructor for performance
      },
    );
  }
}

class OptimizedWordRow extends StatelessWidget {
  const OptimizedWordRow({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        5, // 5 letters per word
        (index) => const LetterTileWidget(),
      ),
    );
  }
}
```

### 7. Security & Data Protection

#### Secure Storage Implementation
```dart
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  
  late final FlutterSecureStorage _secureStorage;
  
  void initialize() {
    const options = AndroidOptions(
      encryptedSharedPreferences: true,
    );
    const iosOptions = IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    );
    
    _secureStorage = const FlutterSecureStorage(
      aOptions: options,
      iOptions: iosOptions,
    );
  }
  
  Future<void> storeUserProgress(String userId, UserProgress progress) async {
    final encrypted = await _encryptData(progress.toJson());
    await _secureStorage.write(key: 'user_progress_$userId', value: encrypted);
  }
  
  Future<UserProgress?> getUserProgress(String userId) async {
    final encrypted = await _secureStorage.read(key: 'user_progress_$userId');
    if (encrypted != null) {
      final decrypted = await _decryptData(encrypted);
      return UserProgress.fromJson(decrypted);
    }
    return null;
  }
  
  Future<String> _encryptData(Map<String, dynamic> data) async {
    // Implement encryption logic
    return jsonEncode(data); // Simplified for example
  }
  
  Future<Map<String, dynamic>> _decryptData(String encrypted) async {
    // Implement decryption logic
    return jsonDecode(encrypted); // Simplified for example
  }
}
```

## Deployment Architecture

### Build Configuration
```yaml
# pubspec.yaml build configuration
flutter:
  assets:
    - assets/images/
    - assets/audio/shona/
    - assets/audio/ndebele/
    - assets/translations/
    - assets/fonts/
  
  fonts:
    - family: ShonaFont
      fonts:
        - asset: assets/fonts/shona_regular.ttf
        - asset: assets/fonts/shona_bold.ttf
          weight: 700
    - family: NdebeleFont
      fonts:
        - asset: assets/fonts/ndebele_regular.ttf
        - asset: assets/fonts/ndebele_bold.ttf
          weight: 700

# Build variants
dev:
  app_name: "Word Game Dev"
  bundle_id: "com.wordgame.dev"
  
staging:
  app_name: "Word Game Staging" 
  bundle_id: "com.wordgame.staging"
  
production:
  app_name: "Shona & Ndebele Word Game"
  bundle_id: "com.wordgame.prod"
```

### Performance Monitoring
```dart
class PerformanceMonitor {
  static void trackGameStart() {
    FirebasePerformance.instance.newTrace('game_start')..start();
  }
  
  static void trackGameEnd(bool isWon, int attempts, Duration gameDuration) {
    final trace = FirebasePerformance.instance.newTrace('game_complete');
    trace.putAttribute('is_won', isWon.toString());
    trace.putAttribute('attempts', attempts.toString());
    trace.putMetric('duration_ms', gameDuration.inMilliseconds);
    trace.stop();
  }
  
  static void trackVocabularyLoad(int wordCount, Duration loadTime) {
    final trace = FirebasePerformance.instance.newTrace('vocabulary_load');
    trace.putMetric('word_count', wordCount);
    trace.putMetric('load_time_ms', loadTime.inMilliseconds);
    trace.stop();
  }
}
```

This technical architecture provides a solid foundation for building a scalable, maintainable, and performant word game application that can effectively serve the Shona and Ndebele language communities while maintaining high code quality and user experience standards.