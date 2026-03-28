# Plan: Build Order Input Section

## Context

The user wants a new section rendered below `SkillOrderSection` (inside `BuildOrdersSection`) that lets users manually create and save new build orders. The section must use the `EditBox` component (from `src/components/EditBox.tsx`) for text fields, matching the WC3 ESC menu style seen in the controls showcase.

Key discovery: The `Renderer` class (`src/renderer/Renderer.ts`) is defined but never instantiated anywhere in the app. `EditBox` requires a `Renderer` prop to register itself in the WebGL element registry, but the CSS class `wc3-editbox` provides all the visual styling. We'll instantiate the Renderer in `App.tsx` and thread it down.

Also: `EditBox` currently only accepts a static `text: string` prop and renders a `<div>`. For a form we need real `<input>` elements — so `EditBox` needs to be extended.

---

## Steps

### 1. Extend `EditBox` to support interactive input
**File:** `src/components/EditBox.tsx`

- Add optional props: `value?: string`, `placeholder?: string`, `onChange?: (v: string) => void`
- When `onChange` is provided, render an `<input>` element instead of the static `<div className="eb-text">` so the field is editable
- Keep backward-compat: when only `text` is provided, render as before

### 2. Instantiate `Renderer` in `App.tsx` and pass it to `BuildOrderPage`
**File:** `src/App.tsx`

- Add `import { Renderer } from './renderer/Renderer'`
- Instantiate once with `useRef`: `const rendererRef = useRef(new Renderer())`
- Pass `renderer={rendererRef.current}` to `BuildOrderPage` via the page registry or direct prop

**File:** `src/pages/index.ts` (or wherever `BuildOrderPage` is registered/rendered)
- Add a `renderer` prop to `BuildOrderPage`

### 3. Thread renderer into `BuildOrderPage` and `BuildOrdersSection`
**File:** `src/pages/BuildOrderPage.tsx`
- Accept `renderer: Renderer` prop and forward to `<BuildOrdersSection renderer={renderer} />`

**File:** `src/components/sections/BuildOrderSection.tsx`
- Accept `renderer: Renderer` prop and pass it to the new `<BuildOrderInputSection>`

### 4. Create `BuildOrderInputSection.tsx`
**File:** `src/components/sections/BuildOrderInputSection.tsx` *(new file)*

Renders a `section-card` below `SkillOrderSection` with a form to create a new build order:

**Fields (using `EditBox`):**
- Build Name (required)
- Race — use existing `GlueDropdown` with `RACES` array
- vs (opponent matchup, optional)
- Difficulty — `GlueDropdown` with `["Beginner", "Intermediate", "Advanced"]`
- Description

**Steps sub-form:**
- A dynamic list of step rows: each row has `time`, `instruction`, `food` fields (EditBox)
- "Add Step" button (GlueSmallButton) appends a new empty row
- Each row has a remove button

**Actions:**
- "Add Build" button (GlueBorderedButton) — validates required fields then calls `importBuilds([newBuild])` from `src/state/buildOrders.ts` and resets the form
- Status message on success/failure (reuse the `build-import-status` pattern from `BuildOrdersSection`)

**Props:**
```ts
interface Props {
  renderer: Renderer;
}
```

### 5. Wire `BuildOrderInputSection` into `BuildOrdersSection`
**File:** `src/components/sections/BuildOrderSection.tsx`

Add below the existing `<SkillOrderSection>` render (inside the `<>` fragment):
```tsx
<BuildOrderInputSection renderer={props.renderer} />
```

---

## Critical Files

| File | Change |
|------|--------|
| `src/components/EditBox.tsx` | Add `value`, `placeholder`, `onChange` props; render `<input>` when interactive |
| `src/App.tsx` | Instantiate `Renderer` with `useRef`; pass to `BuildOrderPage` |
| `src/pages/BuildOrderPage.tsx` | Accept + forward `renderer` prop |
| `src/components/sections/BuildOrderSection.tsx` | Accept `renderer` prop; render `BuildOrderInputSection` |
| `src/components/sections/BuildOrderInputSection.tsx` | **New** — the form component |

## Reused Utilities

- `importBuilds(builds)` from `src/state/buildOrders.ts` — saves new builds to the store
- `GlueDropdown` from `src/components/GlueDropdown` — race and difficulty pickers
- `GlueSmallButton` / `GlueBorderedButton` — add step / submit buttons
- `RACES` array and `RACE_LABELS` from `BuildOrderSection.tsx` — move to shared or duplicate locally
- `build-import-status` CSS class (already in `global.css`) — reuse for success/error messages

## Verification

1. `npm run dev` — navigate to Build Orders page
2. Below the Skill Order section, the new "Add Build Order" form should appear
3. Fill in Name, Race, add at least one step, click "Add Build" → build appears in the dropdown
4. Selecting the new build shows it in the BuildCard
5. EditBox fields should render with `wc3-editbox` WC3 styling
