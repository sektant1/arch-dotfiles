# Plan: Local library consumption (no npm publish)

## Context
The wcui library build is already set up (`npm run build:lib` → `dist/`). The user wants to use it in another React project without publishing to a registry. This plan covers the three local install methods and which to use.

## No code changes needed
The library packaging is already complete. This is purely a usage guide.

---

## Method 1: `file:` path (Recommended for ongoing development)

In the **consumer project's** `package.json`:
```json
{
  "dependencies": {
    "wcui": "file:../wcui"
  }
}
```
Then run `npm install` in the consumer project.

**How it works:** npm copies the `dist/` folder (controlled by `"files": ["dist"]` in wcui's package.json) into `node_modules/wcui`. Re-run `npm install` in the consumer after each `npm run build:lib` in wcui.

**Pros:** Simple. Works without any extra steps beyond building.
**Cons:** Must manually rebuild + reinstall after changes.

---

## Method 2: `npm pack` tarball (Best for one-time testing)

```bash
# In wcui/
npm run build:lib
npm pack
# Creates wcui-0.1.0.tgz

# In consumer project/
npm install ../wcui/wcui-0.1.0.tgz
```

**Pros:** Exactly simulates what a real `npm install wcui` would do. Safe, no symlinks.
**Cons:** Must re-pack and re-install after every change.

---

## Method 3: `npm link` (Best for active co-development with live symlink)

```bash
# In wcui/
npm run build:lib
npm link

# In consumer project/
npm link wcui
```

After any change to wcui, just run `npm run build:lib` — the consumer immediately sees updated `dist/` via symlink without reinstalling.

**Pros:** No reinstall needed after rebuilds. Fastest iteration.
**Cons:** Symlinks can cause React "multiple instances" errors if both projects have their own `node_modules/react`. Fix with:
```bash
# In wcui/, point its react to the consumer's copy:
npm link ../my-consumer-project/node_modules/react
```

---

## Consumer setup (all methods)

After installing, in the consumer project:

```tsx
// src/main.tsx (app entry)
import 'wcui/style.css';

// any component file
import { StatBar, Checkbox, useCurrentRace, setCurrentRace } from 'wcui';
import type { Race } from 'wcui';
```

The consumer must also serve WC3 assets from their `public/` at the expected paths (`/buttons/`, `/bars/`, `/console-buttons/`, etc.).

---

## Recommendation
Use **Method 1 (`file:`)** to start — it's the simplest. Switch to **Method 3 (`npm link`)** if you're actively developing both projects simultaneously.

## Files involved
- `wcui/package.json` — already configured with `"files": ["dist"]` and correct `exports`
- `wcui/dist/` — rebuilt via `npm run build:lib` before any install
