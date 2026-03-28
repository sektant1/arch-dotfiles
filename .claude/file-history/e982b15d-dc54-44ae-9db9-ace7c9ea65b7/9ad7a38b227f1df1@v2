# WC3 Build Order Helper — Architecture & Design

## Context
Learning project to build a Warcraft 3 build order practice tool using React/Redux, Node.js, PostgreSQL, and REST APIs. The app runs on a side monitor while playing WC3, providing a timer that plays sound cues at build order timestamps.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 (Vite + JSX), Redux Toolkit, React Router v6 |
| Backend | Node.js + Express |
| Database | PostgreSQL + `pg` (node-postgres) |
| Audio | Web Audio API (precise scheduling) |
| Styling | CSS Modules (simple, no extra deps) |

**Why Vite over CRA:** Faster dev server, simpler config, CRA is deprecated.
**Why Redux Toolkit over plain Redux:** Still Redux under the hood, but less boilerplate — you learn the same concepts (store, slices, reducers, selectors, thunks).

---

## Project Structure

```
wc3-react/
├── client/                  # React frontend
│   ├── public/
│   │   └── sounds/          # Audio files (.mp3/.wav)
│   ├── src/
│   │   ├── main.jsx         # Entry point
│   │   ├── App.jsx          # Routes + layout
│   │   ├── store/           # Redux store
│   │   │   ├── index.js     # configureStore
│   │   │   ├── buildOrdersSlice.js
│   │   │   ├── timerSlice.js
│   │   │   └── racesSlice.js
│   │   ├── pages/
│   │   │   ├── Home.jsx            # Race selection
│   │   │   ├── BuildOrderList.jsx  # Browse/pick build orders for a race
│   │   │   ├── BuildOrderEditor.jsx # Create/edit a build order
│   │   │   └── Player.jsx          # THE MAIN SCREEN: timer + steps + sounds
│   │   ├── components/
│   │   │   ├── Timer.jsx           # Countdown/countup display + controls
│   │   │   ├── StepList.jsx        # Scrollable list of build steps
│   │   │   ├── StepItem.jsx        # Single step row (highlights when active)
│   │   │   ├── RaceCard.jsx        # Race selection card
│   │   │   └── BuildOrderForm.jsx  # Form for adding/editing steps
│   │   ├── hooks/
│   │   │   └── useTimer.js         # Timer logic (requestAnimationFrame)
│   │   ├── services/
│   │   │   ├── api.js              # Axios/fetch wrapper for REST calls
│   │   │   └── audio.js            # Web Audio API helper
│   │   └── utils/
│   │       └── formatTime.js       # "2:50" formatting helpers
│   ├── index.html
│   └── vite.config.js
│
├── server/                  # Node.js backend
│   ├── index.js             # Express app entry
│   ├── routes/
│   │   ├── races.js         # GET /api/races
│   │   └── buildOrders.js   # CRUD /api/build-orders
│   ├── db/
│   │   ├── pool.js          # pg Pool connection
│   │   ├── migrations/      # SQL migration files
│   │   │   └── 001_initial.sql
│   │   └── seed.js          # Seed premade build orders
│   └── middleware/
│       └── errorHandler.js
│
├── package.json             # Root scripts (concurrently runs client + server)
└── .env                     # DB connection string, ports
```

---

## Database Schema

```sql
CREATE TABLE races (
  id    SERIAL PRIMARY KEY,
  name  VARCHAR(20) UNIQUE NOT NULL,  -- 'Human', 'Orc', 'Undead', 'Night Elf'
  icon  VARCHAR(255)                   -- path or URL to race icon
);

CREATE TABLE build_orders (
  id          SERIAL PRIMARY KEY,
  race_id     INTEGER REFERENCES races(id) ON DELETE CASCADE,
  name        VARCHAR(100) NOT NULL,       -- e.g. "HU Fast Expand"
  description TEXT,
  matchup     VARCHAR(10),                 -- e.g. "HUvOC", "ANY"
  is_premade  BOOLEAN DEFAULT false,
  created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE build_order_steps (
  id              SERIAL PRIMARY KEY,
  build_order_id  INTEGER REFERENCES build_orders(id) ON DELETE CASCADE,
  timestamp_secs  INTEGER NOT NULL,         -- seconds from game start (170 = 2:50)
  action          VARCHAR(200) NOT NULL,    -- "Upgrade to Castle"
  category        VARCHAR(30),              -- 'build', 'upgrade', 'unit', 'hero', 'timing'
  sound_cue       VARCHAR(100),             -- filename in /sounds/ (null = use TTS or default beep)
  sort_order      INTEGER NOT NULL
);
```

**Key decisions:**
- `timestamp_secs` is an integer (seconds), not a time type — simpler to compare against the timer
- `sort_order` separate from `timestamp_secs` because multiple actions can happen at the same timestamp
- `sound_cue` is optional — when null, use a default notification sound or browser Speech Synthesis API for text-to-speech

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/races` | List all 4 races |
| GET | `/api/build-orders?raceId=1` | List build orders, filter by race |
| GET | `/api/build-orders/:id` | Get single build order with all steps |
| POST | `/api/build-orders` | Create build order + steps |
| PUT | `/api/build-orders/:id` | Update build order + steps |
| DELETE | `/api/build-orders/:id` | Delete build order |

Request/response bodies use JSON. Steps are nested inside build order responses:
```json
{
  "id": 1,
  "name": "HU Fast Expand",
  "race": "Human",
  "steps": [
    { "timestamp_secs": 0, "action": "Train Peasant", "category": "unit" },
    { "timestamp_secs": 15, "action": "Send Peasant to gold", "category": "timing" },
    { "timestamp_secs": 170, "action": "Upgrade to Keep", "category": "upgrade" }
  ]
}
```

---

## Redux Store Shape

```js
{
  races: {
    items: [],          // [{ id, name, icon }]
    status: 'idle'      // 'idle' | 'loading' | 'succeeded' | 'failed'
  },
  buildOrders: {
    items: [],          // list view
    current: null,      // single build order with steps (for Player/Editor)
    status: 'idle'
  },
  timer: {
    elapsedSecs: 0,     // current time in seconds
    isRunning: false,
    speed: 1,           // playback speed multiplier (1x, 1.5x, 2x)
    completedStepIds: [] // steps already triggered
  }
}
```

---

## Timer & Audio Mechanism

This is the core feature. Two separate concerns:

### Timer (useTimer hook)
- Uses `requestAnimationFrame` for smooth UI updates
- Tracks elapsed time with `performance.now()` (not setInterval — avoids drift)
- Dispatches `timerTick` to Redux every ~100ms with current `elapsedSecs`
- Supports: start, pause, resume, reset, speed adjustment

### Audio Scheduling (services/audio.js)
- On **play**, pre-load all sound files for the current build order
- Each tick, check if any step's `timestamp_secs <= elapsedSecs` and hasn't been triggered yet
- When a step triggers: play its sound cue + visually highlight it in StepList
- For steps without a custom sound file, use `SpeechSynthesisUtterance` to read the action text aloud (browser TTS — zero audio files needed for basic functionality)
- Web Audio API `AudioContext` for low-latency playback

### Why not pre-schedule with Web Audio API setTimeout?
Pause/resume/speed-change make pre-scheduling complex. Simpler to check on each tick.

---

## Frontend Pages & Flow

```
Home (/) → Pick a race
  ↓
BuildOrderList (/race/:raceId) → Browse/search build orders for that race
  ↓
Player (/play/:buildOrderId) → THE MAIN SCREEN
  - Large timer display at top
  - Step list below (current step highlighted, upcoming visible, past greyed)
  - Controls: Play/Pause, Reset, Speed (1x/1.5x/2x)
  - Auto-scrolls to current step

BuildOrderEditor (/build-orders/new, /build-orders/:id/edit)
  - Form to name the build order, pick race
  - Add steps: timestamp (mm:ss picker) + action text + category dropdown
  - Reorder steps via drag or sort buttons
```

### Player Page Layout (side monitor optimized)
```
┌─────────────────────┐
│      02:50           │  ← large timer
│  ▶ Pause  ↺ Reset   │  ← controls
├─────────────────────┤
│ ✓ 0:00  Train Peon  │  ← completed (grey)
│ ✓ 0:15  Altar       │
│ ► 2:50  Keep ←──────│  ← CURRENT (highlighted + sound)
│   3:30  Blacksmith   │  ← upcoming
│   4:00  Tech         │
└─────────────────────┘
```

Compact, vertical, readable at a glance from your gaming monitor.

---

## Implementation Order

### Phase 1: Project Scaffolding
1. Initialize root `package.json` with `concurrently` for running client + server
2. Scaffold client with `npm create vite@latest client -- --template react`
3. Set up server with Express, basic health check endpoint
4. Set up PostgreSQL database, create tables via migration SQL
5. Seed the 4 races

### Phase 2: Backend API
6. Implement `GET /api/races`
7. Implement CRUD for `/api/build-orders` (with nested steps)
8. Seed 2-3 premade build orders (e.g., HU Fast Expand, OC Blademaster Rush)
9. Test endpoints with curl or Postman

### Phase 3: Frontend Foundation
10. Install Redux Toolkit, React Router, set up store
11. Build Home page (race selection)
12. Build BuildOrderList page (fetch + display build orders)
13. Wire up API calls via `services/api.js`

### Phase 4: The Player (Core Feature)
14. Build `useTimer` hook with `requestAnimationFrame`
15. Build Timer component (display + controls)
16. Build StepList/StepItem with active step highlighting + auto-scroll
17. Implement audio service (TTS for step actions)
18. Connect timer ticks to step triggering + sound playback

### Phase 5: Build Order Editor
19. Build the form for creating/editing build orders
20. Add step management (add, remove, reorder steps)
21. Wire up POST/PUT API calls

### Phase 6: Polish
22. Add speed controls (1x, 1.5x, 2x)
23. Add custom sound files for common actions
24. Responsive/compact styling for side monitor
25. Error handling and loading states

---

## Verification / How to Test
1. `npm run dev` from root starts both client (Vite on :5173) and server (Express on :3000)
2. Visit http://localhost:5173, select a race, pick a premade build order
3. Hit play — timer counts up, steps highlight as timestamps are reached, sounds/TTS play
4. Create a custom build order via the editor, verify it saves and appears in the list
5. Test pause/resume/reset/speed controls during playback
