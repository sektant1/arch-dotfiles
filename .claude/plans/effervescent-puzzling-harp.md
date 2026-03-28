# Plan: Testing @wc3-ui/react in an External Project

## Context

The `@wc3-ui/react` package is fully built (`dist/index.js`, `dist/index.cjs`, `dist/index.d.ts`, `dist/styles.css`). All components are ported and exported. This plan describes how to scaffold a minimal external React project to verify the import works end-to-end.

---

## How it Works

- `WC3RendererProvider` auto-creates a fixed full-viewport WebGL canvas internally — the consumer never touches it directly.
- All components inside the provider register themselves with the renderer at mount time and deregister on unmount.
- The renderer reads textures from paths like `war3/Console/Human/HumanUITile01.png` at runtime via `fetch`/`Image`. These must be served from the consuming app's `public/` folder.
- `war3-model` and `gl-matrix` are **bundled** into the dist — consumers don't need to install them.

---

## Steps

### Step 1 — Scaffold a new Vite React app

```bash
npm create vite@latest wc3-test -- --template react-ts
cd wc3-test
npm install
```

### Step 2 — Reference the local package

In `wc3-test/package.json`, add to `dependencies`:
```json
"@wc3-ui/react": "file:/home/garrosh/repos/warcraft-components/packages/react"
```

Then run:
```bash
npm install
```

This creates a symlink in `node_modules/@wc3-ui/react` pointing to the built `dist/`.

### Step 3 — Copy the game assets

The renderer loads textures relative to the app's public root. Copy the `war3/` folder from the original project:

```bash
cp -r /home/garrosh/repos/warcraft-components/public/war3 wc3-test/public/
```

For 3D model components (`HeroPortraitModel`, `TimeIndicatorModel`, `WorkerUnitModel`) also copy:
```bash
cp -r /home/garrosh/repos/warcraft-components/public/models wc3-test/public/
```

### Step 4 — Write a minimal test component

Replace `wc3-test/src/App.tsx` with:

```tsx
import { useState } from 'react';
import { WC3RendererProvider, StatBar, Tooltip, EditBox, BottomHud } from '@wc3-ui/react';
import type { Race } from '@wc3-ui/react';
import '@wc3-ui/react/styles.css';

export default function App() {
  const [race, setRace] = useState<Race>('Human');
  const [hp, setHp] = useState(75);

  return (
    <WC3RendererProvider race={race}>
      <div style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
        <select value={race} onChange={e => setRace(e.target.value as Race)}>
          <option>Human</option>
          <option>Orc</option>
          <option>NightElf</option>
          <option>Undead</option>
        </select>

        <input type="range" min={0} max={100} value={hp}
          onChange={e => setHp(Number(e.target.value))} />

        <StatBar label="HP" type="health" fillPercent={hp} maxValue={100} />
        <StatBar label="Mana" type="mana" fillPercent={60} maxValue={200} />

        <EditBox text="Type here..." />

        <Tooltip>Blessed by the Ancients</Tooltip>

        <BottomHud race={race} />
      </div>
    </WC3RendererProvider>
  );
}
```

### Step 5 — Run the dev server

```bash
npm run dev
```

Open `http://localhost:5173`. You should see:
- The HP/mana bars styled with WC3 textures (animated)
- A WC3-style edit box
- A tooltip
- The bottom HUD bar with race-specific tile images

---

## Verification Checklist

- [ ] Components mount without console errors
- [ ] The WebGL canvas overlay appears (check DevTools Elements — there should be a `<canvas>` at `position: fixed; z-index: 0`)
- [ ] Switching races re-renders BottomHud and the renderer loads new textures
- [ ] Dragging the HP range input updates the StatBar fill in real time
- [ ] No `Cannot find module '@wc3-ui/react'` errors

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Components render but bars are invisible/flat | Missing `war3/` assets in `public/` | Run the `cp -r` command in Step 3 |
| `SyntaxError: Cannot use import statement` | Node resolving `.ts` source instead of built `.js` | Re-run `npm run build` in `packages/react`, then `npm install` in test app |
| TypeScript can't find types | `dist/index.d.ts` missing | Run `npm run build` in `packages/react` |
| 3D models blank | Missing `models/` assets | Copy models folder per Step 3 |
