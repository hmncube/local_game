-- Phase 1: Core MVP Schema (Launch Ready)

-- 1. Words Table
CREATE TABLE words (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT NOT NULL,
    language TEXT NOT NULL CHECK(language IN ('shona', 'ndebele')),
    word_length INTEGER NOT NULL,
    difficulty INTEGER DEFAULT 2 CHECK(difficulty BETWEEN 1 AND 3),
    english_translation TEXT NOT NULL,
    definition TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    UNIQUE(word, language)
);

-- 2. Users Table
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

-- 3. Game Sessions Table
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

-- 4. Daily Challenges Table
CREATE TABLE daily_challenges (
    challenge_date DATE PRIMARY KEY,
    word_id INTEGER NOT NULL,
    language TEXT NOT NULL,
    bonus_multiplier REAL DEFAULT 1.0,
    FOREIGN KEY (word_id) REFERENCES words(id)
);

-- 5. Levels Table
CREATE TABLE levels (
    id INTEGER PRIMARY KEY,
    status INTEGER DEFAULT 0, -- 0: not done, 1: done
    points INTEGER DEFAULT 0,
    difficulty INTEGER DEFAULT 0,
    finished_at INTEGER,
    started_at INTEGER
);

-- Initial Levels
INSERT INTO levels (id, difficulty) VALUES (1, 1); -- Easy 1
INSERT INTO levels (id, difficulty) VALUES (2, 1); -- Easy 2
INSERT INTO levels (id, difficulty) VALUES (3, 1); -- Easy 3
INSERT INTO levels (id, difficulty) VALUES (4, 2); -- Moderate 1
INSERT INTO levels (id, difficulty) VALUES (5, 2); -- Moderate 2
INSERT INTO levels (id, difficulty) VALUES (6, 2); -- Moderate 3
INSERT INTO levels (id, difficulty) VALUES (7, 3); -- Hard 1
INSERT INTO levels (id, difficulty) VALUES (8, 3); -- Hard 2
INSERT INTO levels (id, difficulty) VALUES (9, 3); -- Hard 3

-- Essential Indexes
CREATE INDEX idx_words_language_active ON words(language, is_active);
CREATE INDEX idx_words_length_difficulty ON words(word_length, difficulty);
CREATE INDEX idx_sessions_user_date ON game_sessions(user_id, played_at DESC);
CREATE INDEX idx_daily_date ON daily_challenges(challenge_date DESC);

-- Simple Triggers for Data Consistency
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
