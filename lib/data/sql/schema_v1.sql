-- Phase 1: Core MVP Schema (Launch Ready)

-- 1. Word Groups Table
-- This table groups translations together. Each row represents a single concept.
CREATE TABLE word_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- 2. Words Table
-- This table stores individual words in different languages, linked by a group_id.
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

-- 3. Users Table
CREATE TABLE users (
    id TEXT PRIMARY KEY, -- UUID
    username TEXT UNIQUE,
    player_icon_id INTEGER,
    preferred_language TEXT,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_score INTEGER DEFAULT 0,
    hints INTEGER DEFAULT 3,
    settings TEXT DEFAULT '{}', -- JSON: {sound: true, vibration: true, dark_mode: false}
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    last_played INTEGER DEFAULT (strftime('%s', 'now'))
);

-- 4. Chapters Table
CREATE TABLE chapters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    title_sn TEXT,
    title_nd TEXT,
    difficulty TEXT,
    levels TEXT
);

-- 5. Levels Table
CREATE TABLE levels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    status INTEGER DEFAULT 0, -- 0: not done, 1: done
    points INTEGER DEFAULT 0,
    difficulty INTEGER DEFAULT 0,
    level_type INTEGER DEFAULT 1,
    finished_at INTEGER,
    started_at INTEGER,
    words_en TEXT,
    words_sn TEXT,
    words_nd TEXT
);

-- 6. Level Words Table (Associative Table)
CREATE TABLE level_words (
    level_id INTEGER NOT NULL,
    word_id INTEGER NOT NULL,
    display_order INTEGER NOT NULL, -- To maintain the order of words within a level, 0 is the main word
    PRIMARY KEY (level_id, word_id),
    FOREIGN KEY (level_id) REFERENCES levels(id) ON DELETE CASCADE,
    FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
);

-- 7. Player Icons Table
CREATE TABLE player_icons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name_en TEXT,
    name_nd TEXT,
    name_sn TEXT,
    path TEXT,
    facts_en TEXT,
    facts_nd TEXT,
    facts_sn TEXT
);

-- Initial Player Icons
INSERT INTO player_icons (name_en, name_nd, name_sn, path, facts_en, facts_nd, facts_sn) VALUES
('Buffalo', 'Imbuffalo', 'Nyati', 'buffalo', 'Buffalo are strong animals that live in large herds for protection.', 'Imbuffalo ziyizilwane ezinamandla ezihlala ngobunengi ukuze zivikelane.', 'Nyati inhoro ine simba inogara mumapoka kuti idzivirirwe.'),
('Crocodile', 'Ingwenya', 'Ngwena', 'crocodile', 'Crocodiles can stay underwater for more than 30 minutes without breathing.', 'Ingwenya zingahlala ngaphansi kwamanzi imizuzu engaphezu kuka-30 zingaphefumuli.', 'Ngwena inogona kugara mumvura kwemaminitsi anopfuura makumi matatu isina kufema.'),
('Giraffe', 'Indlulamithi', 'Tsvimborume', 'giraffe', 'Giraffes are the tallest land animals in the world.', 'Indlulamithi yisilwane eside kakhulu emhlabeni.', 'Tsvimborume ndiyo mhuka refu kupfuura dzese pasi pano.'),
('Leopard', 'Ingwe', 'Shumba', 'leopard', 'Leopards are known for their beautiful spotted coats and climbing ability.', 'Ingwe yaziwa ngokuba lesikhumba esinemabala amahle futhi iyakhwela izihlahla.', 'Shumba nyamuzihwa inozivara zvine mavara akanaka uye inokwira miti.'),
('Lion', 'Ingonyama', 'Shumba', 'lion',
'Lions live in groups called prides and are known as the kings of the jungle.',
'Ingonyama ihlala ngemihlambi ebizwa ngokuthi ama-pride futhi yaziwa njengenkosi yehlathi.',
'Shumba inogara mumapoka anonzi mapridhe uye inozivikanwa semambo wesango.'
),
('Owl', 'Uqhokolo', 'Hukurubwi', 'owl', 'Owls can see clearly at night and turn their heads almost all the way around.', 'Uqhokolo lubona kahle ebusuku futhi luyakwazi ukujika ikhanda cishe ngokupheleleyo.', 'Hukurubwi hunoona zvakanaka usiku uye hunogona kutenderedza musoro kusvika kumashure.');
