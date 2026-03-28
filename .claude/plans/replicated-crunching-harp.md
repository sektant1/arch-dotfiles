# Plan: WC3 Build Order Practice Tool

## Context

This repo is a WC3 UI Component Library showcase (React + TS + Vite) with a custom WebGL renderer, 30+ themed components, and a section-based layout. The user wants to repurpose it into a **learning project** — a build order practice tool that runs on a side monitor during WC3 games, showing a timer with sound cues at build order timestamps. The user wants to keep the existing UI library and learn how it works by extending it.

**Two deliverables:**
1. A `GUIDE.md` that teaches how to add custom sections
2. The build order timer feature itself, built as new sections

---

## Phase 0: GUIDE.md

Create `/home/garrosh/repos/build-order-app/GUIDE.md` covering:

1. **Section pattern** — How `App.tsx` composes sections: each is a component in `src/components/sections/`, rendered inside `<div className="showcase-flow-item">` wrappers. Use `FAQSection.tsx` (simplest) and `FooterSection.tsx` (takes props) as examples.
2. **Creating a section** — Step-by-step: create file, use `section-card` class, export default, import in `App.tsx`, add to render tree.
3. **Adding state** — Create a store in `src/state/` using `createExternalStore` from `createStore.ts`. Follow `resources.ts` pattern: module-level stores, named exports for get/set/hook.
4. **Styling** — Add CSS to `src/global.css`. Reference existing design tokens (gold `#fcd312`, dark bg `#08080f`, Friz Quadrata font).
5. **Using existing components** — List available components (StatBar, LoadingBar, MenuButton, Checkbox, RadioButton, Slider, EditBox, MenuPanel, Tooltip).
6. **Race-aware theming** — How to consume `useCurrentRace()` from `src/state/race.ts`.

---

## Phase 1: Build Order Data Model

**Create `src/lib/buildOrder.ts`:**
```typescript
interface BuildOrderStep {
  timeSeconds: number;  // seconds from game start
  action: string;       // e.g. "Build Altar of Kings"
  supply?: string;      // e.g. "5/12"
  category?: 'unit' | 'building' | 'upgrade' | 'hero' | 'item';
}

interface BuildOrder {
  id: string;           // slug like "human-fast-expand"
  name: string;
  race: Race;
  description: string;
  steps: BuildOrderStep[];
}

function formatTime(seconds: number): string  // => "M:SS"
```

**Create `src/data/presetBuildOrders.ts`:**
- 1-2 presets per race with realistic timestamps (Human fast expand, Orc blade rush, NE DH opener, UD DK expand)

---

## Phase 2: State Stores

**Create `src/state/buildOrder.ts`:**
- `activeBuildOrderStore` — currently selected build order (`BuildOrder | null`)
- `customBuildOrdersStore` — user-created orders (`BuildOrder[]`), persisted to localStorage
- Exports: `useActiveBuildOrder`, `setActiveBuildOrder`, `useCustomBuildOrders`, `addCustomBuildOrder`, `removeCustomBuildOrder`

**Create `src/state/timer.ts`:**
- `timerRunningStore`, `elapsedSecondsStore`, `timerSpeedStore` (1x/1.5x/2x)
- `startTimer()` uses `setInterval(1000 / speed)`, `pauseTimer()`, `resetTimer()`, `seekTimer(seconds)`
- Exports: `useTimerRunning`, `useElapsedSeconds`, `useTimerSpeed`

Reuse `createExternalStore` from `src/state/createStore.ts`, follow `resources.ts` export pattern.

---

## Phase 3: Timer Display Section

**Create `src/components/BuildOrderStepList.tsx`:**
- Scrollable list of steps with time + action
- Highlights current/next step based on `useElapsedSeconds()`
- Past steps dimmed, current step gold-highlighted, auto-scrolls

**Create `src/components/sections/TimerSection.tsx`:**
- Large `M:SS` time display (Friz Quadrata, gold)
- Play/Pause/Reset buttons
- Speed selector (1x / 1.5x / 2x)
- Embeds `BuildOrderStepList`
- Uses `section-card` class

**Modify `src/App.tsx`:** Import and render `TimerSection` after `HeroSection` inside a `showcase-flow-item` wrapper.

**Modify `src/global.css`:** Add timer display, step list, and control styles.

---

## Phase 4: Build Order Selector Section

**Create `src/components/sections/BuildOrderSelectorSection.tsx`:**
- Filters presets by current race via `useCurrentRace()`
- Shows preset + custom build orders as a selectable list
- Clicking sets `activeBuildOrder` and resets timer

**Modify `src/App.tsx`:** Add before `TimerSection`.

---

## Phase 5: Build Order Editor Section

**Create `src/components/sections/BuildOrderEditorSection.tsx`:**
- Two modes: Form and JSON (toggle)
- Form: name, race selector, description, step list editor (time inputs + action text + remove button + add step)
- JSON: textarea for raw JSON paste/edit
- Save calls `addCustomBuildOrder()` or `updateCustomBuildOrder()`

**Create `src/lib/buildOrderValidation.ts`:** Validate build order structure from JSON.

---

## Phase 6: Sound Cues (deferred — user decides approach later)

Placeholder for future: Web Audio API beeps, speech synthesis, or both. The timer store will need a hook point to trigger sounds when `elapsedSeconds` matches a step's `timeSeconds`.

---

## Phase 7: Side-Monitor Polish

- Compact/timer-only mode toggle in App.tsx that hides showcase sections
- Larger fonts for distance readability
- Keyboard shortcuts: Space (play/pause), R (reset), arrows (seek ±5s)

---

## Files Summary

| New Files | Purpose |
|---|---|
| `GUIDE.md` | Learning guide for extending the app |
| `src/lib/buildOrder.ts` | Types + formatTime helper |
| `src/lib/buildOrderValidation.ts` | JSON validation |
| `src/data/presetBuildOrders.ts` | Preset build orders |
| `src/state/buildOrder.ts` | Build order stores |
| `src/state/timer.ts` | Timer stores + controls |
| `src/components/BuildOrderStepList.tsx` | Step list component |
| `src/components/sections/TimerSection.tsx` | Timer display section |
| `src/components/sections/BuildOrderSelectorSection.tsx` | Build order picker |
| `src/components/sections/BuildOrderEditorSection.tsx` | Build order editor |

| Modified Files | Changes |
|---|---|
| `src/App.tsx` | Import + render new sections, view toggle |
| `src/global.css` | Timer, step list, selector, editor styles |

## Key Patterns to Reuse

- **Store pattern**: `src/state/createStore.ts` → `createExternalStore<T>()` returning `{ get, set, useValue }`
- **Store exports**: Follow `src/state/resources.ts` — module-level stores, named get/set/hook exports
- **Section pattern**: Follow `src/components/sections/FAQSection.tsx` — `<section className="section-card">`, default export
- **Section integration**: `App.tsx:3219` — `<div className="showcase-flow-item">` wrapper pattern
- **Button style**: `esc-option-preview` class from `HeroSection.tsx`

## Verification

After each phase:
- `npm run dev` — check the dev server renders without errors
- Visually confirm new sections appear with WC3 theming
- After Phase 3: verify timer starts/pauses/resets, step list highlights correctly
- After Phase 5: create a custom build order, reload page, confirm it persists
- `npm run build` — confirm no TS errors in production build
