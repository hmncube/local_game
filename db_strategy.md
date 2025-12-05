# Simplified Database Plan for Shona & Ndebele Word Game

## Design Philosophy

**Start Simple, Scale Smart**: Build the minimum viable database schema that supports core gameplay, then add complexity only when proven necessary. Focus on delivering a great word-guessing experience first.

## Phase 1: Core MVP Schema (Launch Ready)

### Essential Tables Only

#### 1. Word Groups Table
```sql
CREATE TABLE word_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER DEFAULT (strftime('%s', 'now'))
);
```

#### 2. Words Table
```sql
CREATE TABLE words (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER NOT NULL,
    word TEXT NOT NULL,
    language TEXT NOT NULL CHECK(language IN ('shona', 'ndebele', 'english')),
    word_length INTEGER NOT NULL,
    difficulty INTEGER DEFAULT 2 CHECK(difficulty BETWEEN 1 AND 3),
    definition TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    UNIQUE(word, language),
    FOREIGN KEY (group_id) REFERENCES word_groups(id) ON DELETE CASCADE
);
```

**Why this works**: Normalised structure to support translations. A `word_group` represents a concept, and `words` in different languages can belong to a group.

#### 3. Users Table
```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY, -- UUID
    username TEXT UNIQUE,
    preferred_language TEXT DEFAULT 'shona' CHECK(preferred_language IN ('shona', 'ndebele')),
    total_games INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_score INTEGER DEFAULT 0,
    settings TEXT DEFAULT '{}', -- JSON: {sound: true, vibration: true, dark_mode: false}
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    last_played INTEGER DEFAULT (strftime('%s', 'now'))
);
```

**Why this works**: All essential user data in one place. Basic stats that players actually care about. Settings as JSON for flexibility without table bloat.

#### 4. Game Sessions Table
```sql
CREATE TABLE game_sessions (
    id TEXT PRIMARY KEY, -- UUID
    user_id TEXT NOT NULL,
    word_id INTEGER NOT NULL,
    game_type TEXT DEFAULT 'daily' CHECK(game_type IN ('daily', 'practice')),
    guesses TEXT NOT NULL, -- JSON array of guess objects
    is_completed BOOLEAN DEFAULT FALSE,
    is_won BOOLEAN DEFAULT FALSE,
    attempts_used INTEGER DEFAULT 0,
    score INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    played_at INTEGER DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id)
);
```

**Why this works**: Complete game state in one record. JSON guesses array stores all attempts without separate table complexity.

#### 5. Daily Challenges Table
```sql
CREATE TABLE daily_challenges (
    challenge_date DATE PRIMARY KEY,
    word_id INTEGER NOT NULL,
    language TEXT NOT NULL,
    bonus_multiplier REAL DEFAULT 1.0,
    FOREIGN KEY (word_id) REFERENCES words(id)
);
```

**Why this works**: One word per day per language. Simple and predictable.

### Essential Indexes Only
```sql
-- Critical performance indexes only
CREATE INDEX idx_words_language_active ON words(language, is_active);
CREATE INDEX idx_words_length_difficulty ON words(word_length, difficulty);
CREATE INDEX idx_sessions_user_date ON game_sessions(user_id, played_at DESC);
CREATE INDEX idx_daily_date ON daily_challenges(challenge_date DESC);
```

### Simple Triggers for Data Consistency
```sql
-- Update user stats automatically
CREATE TRIGGER update_user_stats AFTER INSERT ON game_sessions 
WHEN NEW.is_completed = TRUE BEGIN
    UPDATE users SET 
        total_games = total_games + 1,
        games_won = games_won + CASE WHEN NEW.is_won THEN 1 ELSE 0 END,
        current_streak = CASE 
            WHEN NEW.is_won THEN current_streak + 1 
            ELSE 0 
        END,
        longest_streak = MAX(longest_streak, CASE 
            WHEN NEW.is_won THEN current_streak + 1 
            ELSE current_streak 
        END),
        total_score = total_score + NEW.score,
        last_played = NEW.played_at
    WHERE id = NEW.user_id;
END;
```

## Phase 2: Proven Enhancement Features

**Add only after Phase 1 is stable and user feedback validates need**

### Categories (If Word Organization Becomes Important)
```sql
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    color TEXT DEFAULT '#6366F1'
);

-- Add to words table:
ALTER TABLE words ADD COLUMN category_id INTEGER REFERENCES categories(id);
```

### Basic Achievements (If Gamification Shows Value)
```sql
CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    target_value INTEGER NOT NULL,
    badge_icon TEXT
);

CREATE TABLE user_achievements (
    user_id TEXT,
    achievement_id TEXT,
    unlocked_at INTEGER,
    PRIMARY KEY (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Word Learning Progress (If Spaced Repetition Requested)
```sql
CREATE TABLE word_progress (
    user_id TEXT,
    word_id INTEGER,
    encounters INTEGER DEFAULT 1,
    correct_guesses INTEGER DEFAULT 0,
    last_seen INTEGER DEFAULT (strftime('%s', 'now')),
    PRIMARY KEY (user_id, word_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);
```

## Phase 3: Advanced Features (Future Considerations)

**Add only with clear user demand and usage analytics**

### Audio Support
```sql
CREATE TABLE word_audio (
    word_id INTEGER PRIMARY KEY,
    audio_url TEXT,
    local_path TEXT,
    speaker_info TEXT,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);
```

### Cultural Context
```sql
CREATE TABLE cultural_notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    word_id INTEGER NOT NULL,
    note_type TEXT CHECK(note_type IN ('usage', 'cultural', 'regional')),
    content TEXT NOT NULL,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);
```

### Multiplayer Features
```sql
CREATE TABLE multiplayer_rooms (
    id TEXT PRIMARY KEY,
    created_by TEXT NOT NULL,
    room_code TEXT UNIQUE NOT NULL,
    word_id INTEGER,
    max_players INTEGER DEFAULT 4,
    status TEXT DEFAULT 'waiting' CHECK(status IN ('waiting', 'active', 'completed')),
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

## Implementation Strategy

### Week 1-2: Core Setup
1. Implement Phase 1 schema
2. Create basic CRUD operations
3. Build word selection algorithms
4. Test with small dataset (~500 words per language)

### Week 3-4: Game Logic
1. Implement guess validation
2. Build scoring system
3. Daily challenge generation
4. Basic user statistics

### Month 2: Polish & Feedback
1. Deploy MVP to small user group
2. Collect usage analytics
3. Identify most-requested features
4. Plan Phase 2 priorities based on data

### Month 3+: Selective Enhancement
1. Add Phase 2 features only if validated by usage
2. Monitor database performance under real load
3. Optimize indexes based on actual query patterns
4. Consider Phase 3 features only with strong user demand

## Key Success Metrics

**Focus on these metrics to guide enhancement decisions:**

- **Core Gameplay**: Daily active users, session completion rate, average attempts per puzzle
- **Engagement**: Streak lengths, return rate, time spent per session  
- **Learning**: Repeated word encounter improvement, vocabulary retention
- **Technical**: Database query performance, app startup time, crash rate

## Maintenance Philosophy

### Database Rules
- **Every table must have a clear single purpose**
- **Every field must be used by core features**
- **Every index must improve measured query performance**
- **Every trigger must prevent real data inconsistency issues**

### Feature Rules
- **No feature ships without user story validation**
- **Complex features require usage analytics proof**
- **Cultural/educational features need clear learning outcome metrics**
- **Social features need demonstrated engagement improvement**

## Migration Strategy

### Phase 1 → Phase 2
- Use `ALTER TABLE` statements for backward-compatible additions
- Create new tables for wholly new features
- Maintain data migration scripts in version control

### Schema Versioning
```sql
CREATE TABLE schema_version (
    version INTEGER PRIMARY KEY,
    applied_at INTEGER DEFAULT (strftime('%s', 'now')),
    description TEXT
);

INSERT INTO schema_version (version, description) VALUES (1, 'Initial MVP schema');
```

## Conclusion

This simplified approach focuses on:

1. **Rapid time-to-market** with essential features only
2. **Maintainable complexity** that matches team capacity  
3. **Data-driven enhancement** based on actual user behavior
4. **Scalable architecture** that can grow intelligently

Start with the MVP, validate with real users, then enhance based on evidence rather than assumptions. This prevents the common trap of building features nobody uses while ensuring the core experience is solid.

