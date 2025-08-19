# How Phase 1 Tables Support Core Gameplay

Let me walk through exactly how each table is used during actual game sessions and user interactions.

## Game Flow Overview

**Daily Challenge Flow**: User opens app → Check if today's word attempted → Load word → Play game → Save results → Update stats

**Practice Mode Flow**: User selects practice → Get random word by difficulty/language → Play game → Save results → Update stats

## Table Usage In Detail

### 1. Words Table - The Vocabulary Engine

**During Game Setup:**
```sql
-- Get today's daily challenge word
SELECT w.* FROM words w 
JOIN daily_challenges dc ON w.id = dc.word_id 
WHERE dc.challenge_date = date('now') AND w.language = 'shona';

-- Get random practice word (avoiding recently played)
SELECT * FROM words 
WHERE language = 'shona' 
  AND difficulty = 2 
  AND is_active = TRUE
  AND id NOT IN (
    SELECT word_id FROM game_sessions 
    WHERE user_id = ? AND played_at > strftime('%s', 'now', '-7 days')
  )
ORDER BY RANDOM() LIMIT 1;
```

**During Guess Validation:**
```sql
-- Check if guessed word exists in vocabulary
SELECT id FROM words 
WHERE word = ? AND language = ? AND is_active = TRUE;
```

**Real Example**: User playing daily Shona challenge gets word "mukombe" (cup). When they guess "kubvuma" (to agree), system validates it's a real Shona word before processing the guess.

### 2. Users Table - Player State & Progress

**On App Launch:**
```sql
-- Load user profile and current stats
SELECT username, preferred_language, current_streak, total_games, games_won,
       (games_won * 100.0 / NULLIF(total_games, 0)) as win_percentage,
       settings, last_played
FROM users WHERE id = ?;
```

**Real Usage**: Shows "Welcome back, Tinashe! Current streak: 15 days, Win rate: 78%" on home screen.

**Settings Management:**
```sql
-- Update user preferences (stored as JSON)
UPDATE users SET 
    settings = json_set(settings, '$.sound_enabled', false),
    preferred_language = 'ndebele'
WHERE id = ?;
```

**Stats Display**: 
- Home screen shows current streak, total games, win percentage
- Profile page shows longest streak, favorite language, join date
- Settings page loads from JSON: sound, vibration, dark mode preferences

### 3. Game Sessions Table - Complete Game State

**Starting New Game:**
```sql
INSERT INTO game_sessions (id, user_id, word_id, game_type, guesses, played_at)
VALUES (?, ?, ?, 'daily', '[]', strftime('%s', 'now'));
```

**After Each Guess:**
```sql
-- Update session with new guess data
UPDATE game_sessions SET 
    guesses = json_insert(guesses, '$[' || attempts_used || ']', 
        json_object(
            'word', ?,
            'result', ?, -- ['correct', 'present', 'absent', 'absent', 'correct', 'present']
            'timestamp', strftime('%s', 'now')
        )
    ),
    attempts_used = attempts_used + 1
WHERE id = ?;
```

**Game Completion:**
```sql
-- Mark game as finished
UPDATE game_sessions SET 
    is_completed = TRUE,
    is_won = ?,
    score = ?,
    duration_seconds = strftime('%s', 'now') - played_at
WHERE id = ?;
```

**Guess Data Structure Example:**
```json
[
  {"word": "kubva", "result": ["absent", "present", "absent", "absent", "absent"], "timestamp": 1692454800},
  {"word": "mukwa", "result": ["correct", "present", "absent", "absent", "absent"], "timestamp": 1692454820},
  {"word": "mukombe", "result": ["correct", "correct", "correct", "correct", "correct", "correct"], "timestamp": 1692454850}
]
```

**Real Gameplay**: User playing "mukombe" (6 letters):
1. Guess 1: "kubva" → System stores result showing 'u' is in word but wrong position
2. Guess 2: "mukwa" → System stores 'm', 'u' correct positions, 'k' wrong position  
3. Guess 3: "mukombe" → All correct, game won in 3 attempts

### 4. Daily Challenges Table - Consistent Daily Words

**Daily Word Generation (Automated):**
```sql
-- Set tomorrow's daily word (run nightly)
INSERT INTO daily_challenges (challenge_date, word_id, language, bonus_multiplier)
SELECT 
    date('now', '+1 day'),
    w.id,
    'shona',
    CASE 
        WHEN w.difficulty = 3 THEN 1.5 
        WHEN w.difficulty = 1 THEN 0.8 
        ELSE 1.0 
    END
FROM words w
WHERE w.language = 'shona' 
  AND w.is_active = TRUE
  AND w.id NOT IN (
    SELECT word_id FROM daily_challenges 
    WHERE challenge_date > date('now', '-30 days')
  )
ORDER BY RANDOM() LIMIT 1;
```

**Check Daily Progress:**
```sql
-- Has user played today's challenge?
SELECT gs.is_completed, gs.is_won, gs.attempts_used
FROM daily_challenges dc
LEFT JOIN game_sessions gs ON dc.word_id = gs.word_id 
    AND gs.user_id = ? 
    AND date(gs.played_at, 'unixepoch') = dc.challenge_date
WHERE dc.challenge_date = date('now');
```

**Real Usage**: Every day at midnight, system picks new word. Users see "Today's Challenge: 6-letter Shona word" with play button. If already played, shows results instead.

## Core Queries During Gameplay

### Starting a Game Session
```sql
-- Complete game initialization
WITH daily_word AS (
    SELECT w.*, dc.bonus_multiplier
    FROM words w
    JOIN daily_challenges dc ON w.id = dc.word_id
    WHERE dc.challenge_date = date('now')
),
user_today AS (
    SELECT COUNT(*) as played_today
    FROM game_sessions 
    WHERE user_id = ? 
      AND date(played_at, 'unixepoch') = date('now')
      AND game_type = 'daily'
)
SELECT 
    dw.*,
    ut.played_today,
    u.current_streak,
    u.preferred_language
FROM daily_word dw, user_today ut, users u
WHERE u.id = ?;
```

### Processing a Guess
```python
# Application logic using database
def process_guess(session_id, guessed_word, target_word):
    # 1. Validate guess exists in database
    valid = db.execute("SELECT 1 FROM words WHERE word = ? AND language = ?", 
                      [guessed_word, current_language])
    
    if not valid:
        return {"error": "Word not in vocabulary"}
    
    # 2. Calculate letter matches
    result = calculate_letter_matches(guessed_word, target_word)
    
    # 3. Update session
    db.execute("""
        UPDATE game_sessions SET 
            guesses = json_insert(guesses, '$[' || attempts_used || ']', ?),
            attempts_used = attempts_used + 1
        WHERE id = ?
    """, [json.dumps({"word": guessed_word, "result": result}), session_id])
    
    # 4. Check win condition
    if guessed_word == target_word:
        complete_game(session_id, won=True)
```

### Ending a Game
```sql
-- Complete game and calculate score
UPDATE game_sessions SET 
    is_completed = TRUE,
    is_won = ?,
    score = CASE 
        WHEN ? THEN -- if won
            (7 - attempts_used) * 100 * (SELECT bonus_multiplier FROM daily_challenges WHERE challenge_date = date('now'))
        ELSE 0 
    END,
    duration_seconds = strftime('%s', 'now') - played_at
WHERE id = ?;
```

**Scoring Logic**: 
- 6 attempts max, so (7 - attempts_used) × 100 = base score
- Won in 1 guess = 600 points, 2 guesses = 500 points, etc.
- Daily challenge bonus multiplier applies
- Practice games use 1.0 multiplier

## User Experience Flows

### First-Time User Setup
```sql
-- Create new user with defaults
INSERT INTO users (id, username, preferred_language) 
VALUES (?, ?, 'shona');

-- User immediately gets today's challenge
SELECT w.word, w.word_length, w.difficulty, w.english_translation
FROM words w
JOIN daily_challenges dc ON w.id = dc.word_id
WHERE dc.challenge_date = date('now');
```

### Daily Return Visit
```sql
-- Check if user played today's challenge
SELECT 
    CASE 
        WHEN gs.id IS NOT NULL THEN 'completed'
        ELSE 'available'
    END as daily_status,
    u.current_streak,
    w.word_length,
    w.difficulty
FROM users u
CROSS JOIN daily_challenges dc
JOIN words w ON dc.word_id = w.id
LEFT JOIN game_sessions gs ON gs.user_id = u.id 
    AND gs.word_id = w.id 
    AND date(gs.played_at, 'unixepoch') = dc.challenge_date
WHERE u.id = ? AND dc.challenge_date = date('now');
```

### Statistics Display
```sql
-- User profile statistics
SELECT 
    username,
    total_games,
    games_won,
    ROUND(games_won * 100.0 / NULLIF(total_games, 0), 1) as win_percentage,
    current_streak,
    longest_streak,
    total_score,
    datetime(created_at, 'unixepoch') as member_since,
    CASE 
        WHEN last_played > strftime('%s', 'now', '-1 day') THEN 'Today'
        WHEN last_played > strftime('%s', 'now', '-2 days') THEN 'Yesterday'
        ELSE 'More than 2 days ago'
    END as last_active
FROM users WHERE id = ?;
```

## Performance Characteristics

### Expected Query Performance
- **Word lookup**: < 1ms (indexed by language + active status)
- **Daily challenge check**: < 2ms (single date lookup)
- **User stats load**: < 1ms (single user record)
- **Session history**: < 5ms (indexed by user + date)

### Storage Estimates
- **Words**: ~2,000 words × 2 languages = ~100KB
- **Users**: 10,000 users × ~200 bytes = ~2MB
- **Sessions**: 10,000 users × 365 days × 100 bytes = ~365MB/year
- **Daily challenges**: 365 days × 2 languages × 50 bytes = ~36KB/year

**Total Year 1**: Under 400MB for substantial user base

## Why This Works

1. **Single-purpose tables**: Each table has one clear responsibility
2. **Embedded complexity**: JSON fields handle variable data without schema bloat
3. **Performance-focused**: Only essential indexes for actual query patterns
4. **User-centric**: Schema matches how players think about the game
5. **Maintainable**: Simple enough for small team to understand and modify

This design supports all core Wordle-style gameplay while remaining simple enough to implement quickly and maintain long-term. The phased approach ensures you only add complexity when proven necessary by real user behavior.