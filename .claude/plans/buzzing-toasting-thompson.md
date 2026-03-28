# Plan: Migrate PostgreSQL to SQLite

## Context
The project is in early scaffolding — only the schema SQL file and environment config exist; no server code has been written yet. Switching to SQLite now avoids any runtime migration and eliminates the need for a running PostgreSQL server, simplifying local development.

## Files to Change

| File | Action |
|------|--------|
| `server/package.json` | Remove `pg`, add `better-sqlite3` |
| `server/.env` | Remove `DATABASE_URL`, add `DB_PATH` |
| `server/db/migrations/001_initial.sql` | Translate PostgreSQL syntax → SQLite |

## Changes

### 1. `server/package.json`
- Remove `"pg": "^8.20.0"`
- Add `"better-sqlite3": "^9.x"`

### 2. `server/.env`
```
DB_PATH=./db/wc3_buildorders.db
PORT=3000
```

### 3. `server/db/migrations/001_initial.sql`
SQLite syntax differences to fix:
- `SERIAL PRIMARY KEY` → `INTEGER PRIMARY KEY AUTOINCREMENT`
- `VARCHAR(n)` → `TEXT`
- `BOOLEAN` → `INTEGER` (0/1)
- `TIMESTAMP DEFAULT NOW()` → `TEXT DEFAULT (datetime('now'))`

Updated schema:
```sql
CREATE TABLE races (
  id    INTEGER PRIMARY KEY AUTOINCREMENT,
  name  TEXT UNIQUE NOT NULL,
  icon  TEXT
);

CREATE TABLE build_orders (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  race_id     INTEGER REFERENCES races(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  matchup     TEXT,
  is_premade  INTEGER DEFAULT 0,
  created_at  TEXT DEFAULT (datetime('now'))
);

CREATE TABLE build_order_steps (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  build_order_id  INTEGER REFERENCES build_orders(id) ON DELETE CASCADE,
  timestamp_secs  INTEGER NOT NULL,
  action          TEXT NOT NULL,
  category        TEXT,
  sound_cue       TEXT,
  sort_order      INTEGER NOT NULL
);

PRAGMA foreign_keys = ON;
```

Note: SQLite foreign keys are off by default — `PRAGMA foreign_keys = ON` must be run on each connection (will handle this in `db/pool.js` when it's created).

## Verification
1. `cd server && npm install` — should pull in `better-sqlite3`, drop `pg`
2. Review `server/db/migrations/001_initial.sql` for valid SQLite syntax
3. When `pool.js` is later created, run the migration with `better-sqlite3` to confirm tables are created without errors
