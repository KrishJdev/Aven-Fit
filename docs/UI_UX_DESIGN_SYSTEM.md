# Aven Fit — UI/UX Design System

> **Version:** 2.0  
> **Status:** Authoritative — supersedes all prior UI conventions  
> **Scope:** All current and future screens, components, and interactions  
> **Last updated:** 2026-09-26

---

## Purpose

This document is the **single source of truth** for every visual and interaction design decision in Aven Fit. Any coding agent building, redesigning, extending, or refactoring the frontend must follow the rules, patterns, and tokens defined here.

The design system is **not a fixed screen map**. It defines rules and patterns that scale to any number of screens, features, and workflows — present or future.

When this document and older documentation (ARCHITECTURE.md, FEATURES.md, HANDOFF.md) conflict on visual or interaction matters, **this document wins**.

---

## 1. Product Visual Personality

Aven Fit should feel like a **real, mature consumer product** — not a college project, admin dashboard, template, or AI demo.

### The personality in five words

**Calm · Precise · Premium · Focused · Trustworthy**

### What this means in practice

| Attribute | Expressed through | NOT expressed through |
|:---|:---|:---|
| Calm | Generous whitespace, muted palette, quiet transitions | Constant animations, bright splashes, gamification noise |
| Precise | Aligned numerals, consistent spacing, typographic hierarchy | Loose layouts, arbitrary padding, decorative elements |
| Premium | Restraint, quality typography, intentional color, polish | Gradients, glow effects, excessive glassmorphism, shimmer |
| Focused | One clear purpose per screen, visible primary action | Information overload, competing CTAs, visual clutter |
| Trustworthy | Accurate data display, neutral tone, no judgment colors | Motivational gimmicks, misleading charts, nag patterns |

### The governing philosophy

> **"Clarity first, visual polish second, decoration last."**

Visual polish comes from typography, spacing, hierarchy, alignment, proportions, consistency, restrained color, and meaningful motion — **not** from gradients, glassmorphism, glowing effects, floating shapes, excessive shadows, decorative blobs, or constant animation.

---

## 2. Core Design Principles

Every UI decision must satisfy these principles. When in doubt, these are the tiebreakers.

### 2.1 Clarity
Users must immediately understand what the current screen is for and what action is most important. If a screen requires explanation, it is too complex.

### 2.2 Hierarchy
Important information must visually dominate secondary information. Size, weight, color, and position all communicate rank. Every screen has exactly one primary focus.

### 2.3 Consistency
A component that represents the same concept must look and behave identically throughout the application. Same data, same pattern — always.

### 2.4 Restraint
Do not add visual elements merely because they can be added. Every pixel must earn its place. When unsure whether to add or remove, remove.

### 2.5 Focus
Each screen or major view should have a single clear primary purpose. If a screen tries to do three things, it probably needs to be split or restructured.

### 2.6 Progressive Disclosure
Show the information users need first. Reveal deeper detail through expansion, navigation, or interaction — not by dumping everything onto one surface.

### 2.7 Data Readability
Fitness and nutrition data must be visually understandable without interpretation effort. Numbers should communicate at a glance. Charts should answer a question, not decorate a page.

### 2.8 Accessibility
The UI must remain usable across different screen sizes, text sizes, lighting conditions, and accessibility settings. This is a constraint, not an afterthought.

### 2.9 Familiarity
Controls should behave in ways users already understand. Diverge from platform conventions only when there is a compelling product reason, and document why.

### 2.10 Feedback
User actions must produce clear but restrained feedback. Taps respond. Saves confirm. Errors explain. But nothing bounces, flashes, or celebrates without purpose.

### 2.11 Trust
Numbers, progress, nutrition information, and health-related data must be presented clearly without misleading visual treatment. No exaggeration, no judgment, no manipulation.

### 2.12 Scalability
The design system must remain coherent as features are added. A pattern that works for 5 items must also work for 50. A layout that works for one metric must accommodate ten.

---

## 3. Visual Language

### 3.1 Overall Style

Dark-mode only. OLED-optimized with true black backgrounds. Clean, typographic, and data-forward. The visual language is closer to a precision instrument than a lifestyle brand.

**Reference aesthetic:** Think of apps like Oura Ring, Whoop, or the Apple Health summary — not Instagram, Duolingo, or MyFitnessPal. Information density managed through hierarchy, not visual noise.

### 3.2 Visual Density

Medium density. Not cramped like a spreadsheet, not wasteful like a marketing page. Content should breathe but screens should not feel empty on a 6.5" phone. One thumb-scroll depth of content should always be visible above the fold.

### 3.3 Whitespace Philosophy

Whitespace is structural, not decorative. It separates logical groups, establishes hierarchy, and gives the eye rest between data sections. Use the spacing scale (§7) consistently. Never add arbitrary gaps to "fill space."

### 3.4 Shape Language

**Softly rounded.** Not sharp/angular, not pill-shaped. A subtle, consistent corner radius that communicates modern software without drawing attention to itself.

- Small interactive elements: `8px` radius
- Cards and containers: `12px` radius  
- Bottom sheets and modals: `16px` top radius
- Full-pill shapes: **Only** for tags, badges, and small status indicators

Zero-radius (sharp edges) is **retired** from the design system. It created a harsh, cold aesthetic that felt uncomfortable in daily use.

### 3.5 Surface Hierarchy

Three surface levels, clearly distinguished:

1. **Background** — True black (`#000000`). The base canvas. Most of the screen.
2. **Surface** — Slightly elevated dark (`#0A0A0A` to `#111111`). Cards, sections, containers.
3. **Elevated Surface** — Modal/sheet level (`#141414` to `#1A1A1A`). Bottom sheets, dialogs, dropdowns.

Surfaces are distinguished by **subtle background color shifts**, not by shadows or borders. Borders are used sparingly for interactive containers (inputs, selected states) — never as the primary surface differentiator.

### 3.6 Border Philosophy

Borders are **functional, not decorative**.

- **Use borders for:** Input fields, selected/active state indicators, interactive card boundaries when tap target clarity is needed
- **Do NOT use borders for:** Every container, every card, every section. A card on a dark background is already visually distinct through its fill color

When borders are used, they should be `1px`, subtle (`rgba(255,255,255,0.08)` to `rgba(255,255,255,0.12)`), and consistent.

### 3.7 Shadow Philosophy

**Minimal shadows.** On an OLED dark interface, shadows are nearly invisible and waste rendering effort. Use elevation through color differentiation, not drop shadows.

Exception: Floating action elements (FABs, floating snackbars) may use a very subtle shadow (`0, 2, 8, rgba(0,0,0,0.3)`) for depth cue.

### 3.8 Icon Style

Lucide Icons — outlined style, consistent 1.5px stroke weight. See §10 for full iconography rules.

### 3.9 Illustration Philosophy

**No illustrations.** No stock art, no decorative SVGs, no mascots, no background patterns. Empty states use an icon + text, never an illustration. If a future feature genuinely requires illustration (e.g., exercise form demos), define it as a content asset, not a decorative element.

### 3.10 Image Usage

Images appear only when they represent real content (e.g., user profile photos, exercise demonstration images if added). Never use images as decoration, backgrounds, or placeholders.

### 3.11 Decorative Element Policy

**None.** No background gradients, no floating shapes, no abstract blobs, no particle effects, no decorative lines, no ornamental dividers. Every visual element must carry information or define structure.

---

## 4. Color System

### 4.1 Semantic Color Roles

Colors are defined by their **role**, not their hue. All code should reference semantic names, never raw hex values.

#### Background & Surface

| Token | Value | Role |
|:---|:---|:---|
| `background` | `#000000` | OLED black. Primary screen background. |
| `surface` | `#0A0A0A` | Card fills, list item backgrounds, containers. |
| `surfaceElevated` | `#141414` | Bottom sheets, dialogs, dropdown overlays. |
| `surfaceActive` | `#1A1A1A` | Active/selected item backgrounds, pressed states. |

#### Brand & Accent

| Token | Value | Role |
|:---|:---|:---|
| `primary` | `#00D4AA` | Primary accent. Interactive elements, focus rings, active tab indicators, progress fills, primary buttons. A calmer teal-cyan — not neon. |
| `primaryMuted` | `#00D4AA` at 15% | Subtle primary backgrounds (selected chip fills, active row tints). |
| `secondary` | `#C8E640` | Positive deltas, PR badges, success accents. A softer yellow-green — not electric. |
| `secondaryMuted` | `#C8E640` at 15% | Subtle positive backgrounds. |
| `warning` | `#E8772E` | Warnings, destructive action accents, error states. Warm amber-orange. |
| `warningMuted` | `#E8772E` at 15% | Subtle warning backgrounds. |

#### Text

| Token | Value | Role |
|:---|:---|:---|
| `textPrimary` | `#FFFFFF` | Primary text. Headings, body, values. |
| `textSecondary` | `#FFFFFF` at 55% | Secondary text. Subtitles, labels, helper text, timestamps. |
| `textMuted` | `#FFFFFF` at 35% | Tertiary text. Placeholders, disabled text, captions. |
| `textOnPrimary` | `#000000` | Text on primary-colored backgrounds. |

#### Structural

| Token | Value | Role |
|:---|:---|:---|
| `border` | `#FFFFFF` at 8% | Subtle borders for inputs, containers when needed. |
| `borderFocused` | `primary` | Focused input borders. |
| `divider` | `#FFFFFF` at 6% | Section dividers. Thin, nearly invisible. |
| `disabled` | `#FFFFFF` at 20% | Disabled controls and text. |
| `overlay` | `#000000` at 60% | Modal overlays, scrim behind sheets. |

#### Semantic States

| Token | Value | Role |
|:---|:---|:---|
| `success` | `secondary` | Confirmations, completed states, positive feedback. |
| `error` | `warning` | Errors, validation failures, destructive actions. |
| `info` | `primary` | Informational states, tips, neutral highlights. |

### 4.2 Color Usage Rules

1. **A typical screen should be 85-90% black/dark grey, 5-10% white text, and 2-5% accent color.** Color is for emphasis, not decoration.
2. **Primary color** appears on: active tab indicator, primary button fills, toggle-on states, progress bar fills, focused input borders, links.
3. **Secondary color** appears on: PR badges, positive delta indicators (+5%), success confirmations. It is **not** a second interactive color.
4. **Warning color** appears on: error messages, destructive button text, validation errors, warning banners. Never decorative.
5. **Never use color to convey nutrition adherence judgment.** No red for "over calories," no green for "under." Progress bars use `primary` fill on a neutral track regardless of adherence (Law L4).
6. **No additional accent colors.** Three accent colors (primary, secondary, warning) are sufficient. Adding purple, blue, pink, or other hues violates the restrained palette.
7. **Muted variants** are for background tints only (selected chip, active list item). They should be barely visible — a whisper of color, not a wash.

### 4.3 Future Theme Support

The system is designed dark-only for the current product. If a light theme is added in the future, the semantic token structure remains identical — only the values change. All code must reference tokens, never hardcoded hex values.

---

## 5. Typography

### 5.1 Font Families

| Family | Role | Format |
|:---|:---|:---|
| **Inter** | All UI text — headings, body, labels, buttons, navigation | Variable weight, bundled TTF (offline-safe) |
| **JetBrains Mono** | All numeric/statistical display — weights, reps, calories, timers, dates | Tabular figures enabled, bundled TTF |

Both fonts are **bundled as local assets** and never fetched from the network (Law L2).

### 5.2 Type Scale

A constrained type scale. Every text element in the app maps to one of these levels. **Do not invent intermediate sizes.**

| Level | Size | Weight | Letter Spacing | Line Height | Usage |
|:---|:---:|:---:|:---:|:---:|:---|
| `display` | 28px | 700 | -0.5px | 1.2 | Screen hero numbers (today's calories, workout duration) |
| `heading` | 20px | 700 | -0.3px | 1.3 | Screen titles, section headings |
| `title` | 16px | 600 | 0px | 1.4 | Card titles, subsection headings, dialog titles |
| `body` | 14px | 400 | 0px | 1.5 | Primary body text, descriptions, instructions |
| `bodyMedium` | 14px | 500 | 0px | 1.5 | Slightly emphasized body text, list item primary lines |
| `label` | 12px | 600 | 0.3px | 1.3 | Section labels ("THIS WEEK"), chip text, button labels, navigation labels |
| `caption` | 11px | 500 | 0.2px | 1.3 | Timestamps, helper text, secondary metadata |

### 5.3 Numeric Typography

All numeric values use **JetBrains Mono** with tabular figures enabled. This ensures:
- Digits align vertically in columns (set tables, macro breakdowns)
- Timers don't "jump" as digits change width
- Statistical displays feel precise and trustworthy

| Context | Size | Weight | Color |
|:---|:---:|:---:|:---|
| Hero stat (calories remaining, workout duration) | 28-32px | 700 | `textPrimary` |
| Primary metric (weight, total volume) | 18-20px | 600 | `textPrimary` |
| Inline stat (set weight, reps, rest timer) | 14-16px | 500 | `textPrimary` |
| Secondary stat (delta, percentage, subtitle value) | 12-13px | 500 | `textSecondary` |
| Micro stat (badges, tiny counters) | 10-11px | 600 | varies |

### 5.4 Typography Rules

1. **Never use ALL CAPS for body text or descriptions.** ALL CAPS is reserved for: section labels ("RECENT WORKOUTS"), button text ("FINISH"), tiny badges ("PR"), and navigation labels.
2. **ALL CAPS text must use letter spacing of 0.5-1.0px** to maintain readability.
3. **Heading weight is 600-700.** Body weight is 400-500. Do not use 800-900 weights — they create visual heaviness.
4. **One heading level per logical section.** Do not stack `display` → `heading` → `title` in three consecutive lines.
5. **Large numbers should feel important without overwhelming.** A `display`-size calorie count is fine as a screen hero. But not every number on the screen should be `display` size.
6. **Ellipsis over wrapping** for single-line labels (exercise names in compact views). Multi-line wrapping only for descriptive text and notes.

---

## 6. Spacing System

### 6.1 Scale

An 4px-based scale. Every spacing value in the app must come from this set.

| Token | Value | Usage |
|:---|:---:|:---|
| `xxs` | 2px | Inline text gaps, icon-to-superscript |
| `xs` | 4px | Tight internal padding, badge padding |
| `sm` | 8px | Compact spacing, list item internal gaps, chip padding |
| `md` | 12px | Standard component internal padding, between related items |
| `lg` | 16px | Screen edge padding, section internal padding, between sections |
| `xl` | 20px | Major section gaps |
| `xxl` | 24px | Screen top/bottom padding, between major groups |
| `xxxl` | 32px | Large visual breaks, hero spacing |

### 6.2 Application Rules

| Context | Token | Value |
|:---|:---|:---:|
| Screen horizontal padding | `lg` | 16px |
| Screen top padding (below safe area) | `md`-`lg` | 12-16px |
| Screen bottom padding | `xxl` | 24px |
| Between sections | `xl` | 20px |
| Between items in a list | `sm`-`md` | 8-12px |
| Card internal padding | `lg` | 16px |
| Within a row of related elements | `sm` | 8px |
| Icon-to-text gap | `sm` | 8px |
| Button internal horizontal padding | `lg` | 16px |
| Button internal vertical padding | `md` | 12px |
| Bottom sheet top padding | `xl` | 20px |
| Between form fields | `lg` | 16px |

### 6.3 Spacing Rules

1. **Use the scale.** Never invent a 7px or 13px or 18px gap. If the scale doesn't have the right size, the design needs adjustment, not a new spacing value.
2. **Consistent direction.** Section spacing is always vertical. Horizontal spacing within rows uses the same token for all items.
3. **Safe area awareness.** Always use `SafeArea` for screen edges. Bottom navigation overlap is handled by the shell — content screens do not need extra bottom padding for the nav bar.

---

## 7. Shape Language

### 7.1 Corner Radius Scale

| Token | Value | Usage |
|:---|:---:|:---|
| `radiusNone` | 0px | Never used as a design choice. Only for technical reasons (e.g., clipping artifacts). |
| `radiusSm` | 8px | Buttons, inputs, chips, small interactive elements |
| `radiusMd` | 12px | Cards, containers, list item backgrounds, dialogs |
| `radiusLg` | 16px | Bottom sheets (top corners), modals, image containers |
| `radiusFull` | 999px | Badges, tags, avatar circles, small status indicators, pills |

### 7.2 Rules

1. **One radius per component type.** All cards use `radiusMd`. All buttons use `radiusSm`. No exceptions.
2. **Nested radius rule.** An inner element's radius should be the outer element's radius minus the padding. If a card has `12px` radius and `16px` padding, inner elements can use `radiusSm` (8px) or none.
3. **Pill radius (`radiusFull`) is restricted** to: badges, small tags, avatar containers, and horizontal progress indicator track ends. It is **not** for buttons, cards, or containers.

---

## 8. Elevation, Borders, and Surfaces

### 8.1 Surface Hierarchy

```
Level 0: background (#000000) — Screen canvas
Level 1: surface (#0A0A0A)    — Cards, sections, list items
Level 2: surfaceElevated (#141414) — Bottom sheets, dialogs, dropdown menus
Level 3: overlay (scrim + surfaceElevated) — Modal overlays
```

### 8.2 Rules

1. **Surfaces differentiate through color, not shadow.** On OLED black, a `#0A0A0A` fill is clearly distinct from `#000000`. Shadows add nothing.
2. **Maximum two surface levels visible on any screen** (background + surface, or surface + elevated). Three nested levels create visual confusion.
3. **Cards do not nest.** A card inside a card is a design smell. If content needs sub-grouping within a card, use section dividers or spacing.
4. **Borders are used sparingly.** A surface card on a black background does not need a border — the fill color provides sufficient contrast. Borders appear on: inputs (always), selected/focused states, and interactive containers where the tap target boundary must be explicit.
5. **Elevation shadows are near-zero.** If a shadow is used at all, it should be `blur: 8, spread: 0, offset: (0, 2), color: #000000 at 30%`.

---

## 9. Iconography

### 9.1 System

**Lucide Icons Flutter** — the sole icon library. All icons are outlined style with consistent 1.5px stroke weight.

### 9.2 Sizing

| Context | Size |
|:---|:---:|
| Navigation bar icons | 22px |
| Inline action icons (app bar, list trailing) | 20px |
| Section header icons | 18px |
| Small inline indicators | 16px |
| Badge/status icons | 14px |
| Empty state feature icons | 28px |

### 9.3 Rules

1. **Every icon must add information.** If removing the icon doesn't reduce comprehension, remove it.
2. **No decorative icons.** Icons next to section headings are acceptable only if the section is in a list of peers (e.g., settings items). A standalone section heading does not need an icon.
3. **Icon color follows text hierarchy.** Primary action icons use `textPrimary`. Secondary/passive icons use `textSecondary`. Interactive icons in their active state use `primary`.
4. **Icon-to-text spacing** is consistently `8px` (the `sm` token).
5. **No icon-only buttons without tooltips.** Every `IconButton` must have a `tooltip` for accessibility.
6. **Consistent metaphors.** Once an icon represents a concept (e.g., `LucideIcons.dumbbell` = workouts), it must represent that concept everywhere. Maintain a mental icon registry.

---

## 10. Component System

### 10.1 Buttons

#### Primary Button (Filled)
- **Fill:** `primary` color
- **Text:** `textOnPrimary`, `label` typography (12px, 600 weight, 0.3px spacing)
- **Height:** 48px
- **Radius:** `radiusSm` (8px)
- **Width:** Full-width for primary page actions. Intrinsic-width for inline actions.
- **Use for:** The single most important action on a screen (Start Workout, Log Food, Save, Finish).
- **Rule:** Maximum ONE primary button per screen at any time.

#### Secondary Button (Outlined)
- **Border:** `primary` color, 1px
- **Text:** `primary` color, `label` typography
- **Fill:** transparent
- **Height:** 48px
- **Radius:** `radiusSm` (8px)
- **Use for:** Secondary actions (Cancel, View All, Edit). Important but not the primary path.

#### Tertiary Button (Text)
- **Text:** `primary` or `textSecondary`, `label` typography
- **Fill:** none
- **Use for:** Inline actions (Clear Filters, Change Number, View History), cancel actions in dialogs.

#### Destructive Button
- **Text:** `warning` color, `label` typography
- **Use for:** Delete, Discard, Sign Out — always behind a confirmation dialog.

#### Icon Button
- **Size:** 40×40px minimum tap target
- **Icon:** 20px
- **Use for:** App bar actions, inline row actions, toggle controls.

### 10.2 Text Fields

- **Background:** `surface`
- **Border:** `border` (default), `borderFocused` / `primary` (focused), `warning` (error)
- **Radius:** `radiusSm` (8px)
- **Height:** 48px
- **Internal padding:** 12px horizontal, centered vertically
- **Label:** Above the field, `caption` typography, `textSecondary`
- **Helper text:** Below the field, `caption` typography, `textMuted`
- **Error text:** Below the field, `caption` typography, `warning` color
- **Prefix/suffix:** `textSecondary` color, vertically centered

### 10.3 Search Fields

- Same as text fields but with:
- Leading search icon (`LucideIcons.search`, `textMuted`)
- Trailing clear button (only when populated)
- No label above (placeholder text serves as the label)

### 10.4 Chips

- **Background:** `surface` (default), `primaryMuted` (selected)
- **Border:** `border` (default), `primary` (selected)
- **Text:** `textSecondary` (default), `primary` (selected), `label` typography
- **Radius:** `radiusSm` (8px)
- **Height:** 32px
- **Horizontal padding:** 12px
- **Use for:** Filters (muscle group, equipment, meal type), multi-select options, tags.
- **Do NOT use for:** Navigation, primary actions, or status display.

### 10.5 Stat Blocks

A core pattern in this fitness app. Used for displaying key metrics.

#### Hero Stat
- **Number:** `display` numeric typography (28-32px, JetBrains Mono)
- **Label:** Below the number, `caption` typography, `textSecondary`, ALL CAPS
- **Use for:** One to three headline metrics at the top of a dashboard (e.g., Calories Remaining, Workout Duration, Weekly Volume).

#### Stat Row
- **Layout:** Horizontal row of 2-4 stat items, evenly distributed
- **Number:** `title` or `bodyMedium` numeric typography (14-16px)
- **Label:** Below or beside the number, `caption` typography, `textSecondary`
- **Use for:** Secondary metric groups (Sets, Volume, PRs, Duration)

#### Inline Stat
- **Layout:** Label and value on the same line, label left, value right
- **Label:** `body` typography, `textSecondary`
- **Value:** `bodyMedium` numeric typography, `textPrimary`
- **Use for:** Detail screens, list item metadata

### 10.6 Lists

- **Item height:** Minimum 56px for single-line, taller as needed for multi-line
- **Item background:** Transparent on `background`, or `surface` fill for grouped lists
- **Dividers:** Between items only when on the same background. Use `divider` color, `0.5px`. Within a `surface` card, dividers separate items; on `background`, spacing separates items.
- **Leading:** Icon (20px, `textSecondary`) or avatar
- **Title:** `bodyMedium` typography, `textPrimary`
- **Subtitle:** `caption` typography, `textSecondary`
- **Trailing:** Value/stat (numeric typography), icon button, or chevron
- **Tap target:** Full width, full height. Ripple/splash feedback.

### 10.7 Section Headers

- **Text:** `label` typography (12px, 600 weight), ALL CAPS, `textSecondary`
- **Spacing:** `xl` (20px) above, `md` (12px) below
- **Optional trailing:** Action text ("VIEW ALL") in `primary` color, `label` typography
- **No icons** unless disambiguating between peer sections in a list

### 10.8 Progress Indicators

#### Linear Progress Bar
- **Track:** `surface` or `border` color fill
- **Fill:** `primary` color
- **Height:** 4px (compact), 8px (standard)
- **Radius:** `radiusFull` on track ends
- **Label:** Optional, above or beside, showing value/target
- **Rule:** Fill should represent actual progress proportionally. Clamp at 100% visually — the text value can exceed 100%.

#### Circular Progress (if used)
- **Track:** `border` color
- **Fill:** `primary` color
- **Stroke:** 4px
- **Center content:** Numeric value or percentage
- **Use sparingly.** Linear bars are preferred for most contexts. Circular progress is appropriate only for a single hero metric (e.g., daily calorie goal).

### 10.9 Badges & Tags

- **Shape:** `radiusFull` (pill)
- **Height:** 20-24px
- **Padding:** 6-8px horizontal
- **Text:** `caption` typography or smaller, 600 weight
- **Colors:** `primary`/`primaryMuted` (neutral info), `secondary`/`secondaryMuted` (positive — PR, success), `warning`/`warningMuted` (alert)
- **Use for:** PR indicators, count badges, status labels, food category tags

### 10.10 Dialogs

- **Surface:** `surfaceElevated`
- **Radius:** `radiusMd` (12px)
- **Padding:** `xl` (20px)
- **Title:** `title` typography
- **Body:** `body` typography, `textSecondary`
- **Actions:** Right-aligned, tertiary (cancel) + primary/destructive (confirm)
- **Scrim:** `overlay` color
- **Rule:** Dialogs are for confirmations and small inputs only. Complex forms go in bottom sheets or full screens.

### 10.11 Bottom Sheets

- **Surface:** `surfaceElevated`
- **Top radius:** `radiusLg` (16px)
- **Handle:** Centered, 36×4px, `border` color, `radiusFull`
- **Padding:** `xl` (20px) horizontal, `lg` (16px) top (below handle)
- **Max height:** 85% of screen height
- **Scrim:** `overlay` color
- **Use for:** Multi-option selections, editing single-field values, exercise info, filter panels

### 10.12 Snackbars

- **Surface:** `surfaceElevated` or `surface`
- **Radius:** `radiusSm` (8px)
- **Position:** Floating, above bottom navigation
- **Duration:** 3-4 seconds default
- **Action:** Optional single text action in `primary` color
- **Use for:** Non-blocking confirmations (item logged, routine saved), recoverable errors (save failed — RETRY)
- **Do NOT use for:** Critical errors (use inline error states), success celebrations (subtle is enough)

### 10.13 Empty States

- **Icon:** 28px, `textMuted` color
- **Title:** `title` typography, `textSecondary`
- **Message:** Optional, `body` typography, `textMuted`
- **Action:** Optional single button, secondary style
- **Tone:** Factual and helpful. "No workouts yet" + "Start your first workout" — not "It's empty in here! 😢"
- **No illustrations.** No large decorative images.

### 10.14 Loading States

- **Skeleton loaders** for content areas (static grey bars hinting at the content shape)
- **Inline spinners** (16-20px) for button loading states
- **No full-screen spinners.** The skeleton pattern preserves layout stability.
- **No shimmer animations** on budget phones (performance concern)

### 10.15 Error States

- **Icon:** `warning` color warning icon
- **Title:** `title` typography, "Something went wrong" or context-specific
- **Message:** `body` typography, `textSecondary`, the actual error in user-friendly terms
- **Action:** RETRY button (secondary style, `primary` color)
- **Rule:** Every error state must have a recovery path. Errors are never dead ends.

### 10.16 Timers & Counters

- **Font:** JetBrains Mono, tabular figures
- **Format:** `MM:SS` for durations, no leading zeros on hours unless > 1 hour
- **Ticking:** Update the display every 1 second using epoch-math recomputation, never accumulated counting (drift-proof, Law L8)
- **Rest timer display:** Compact bar, not a modal. Must not obscure workout content.

### 10.17 Steppers

For quantity input (weight, reps, servings):
- **Layout:** `[-]` value `[+]` horizontal row
- **Button size:** 36×36px minimum tap target
- **Value:** Numeric typography, centered
- **Step increments:** Context-appropriate (±2.5kg for weight, ±1 for reps, ±0.5 for servings)
- **Long-press:** Accelerate increment speed
- **Tap on value:** Open a direct numeric input dialog

### 10.18 Expandable Content

- **Trigger:** Chevron icon (↓/↑) or tap on section header
- **Animation:** 200ms ease-in-out height transition
- **Content:** Revealed below, with `md` (12px) top padding
- **Use for:** Exercise notes, detailed macro breakdown, historical set data

---

## 11. Cards — When and How

### 11.1 Why Cards Exist

Cards create **bounded, visually distinct containers** for content that represents a **single, independent entity** — a workout session, a food item, a routine, a PR record. They communicate "this is one thing."

### 11.2 When to Use Cards

✅ Use a card when:
- The content represents a discrete, tappable entity (a workout, a routine, a food item)
- The content can be reordered, dismissed, or acted upon independently
- The content appears in a list of peers (a list of routines, a history feed)

### 11.3 When NOT to Use Cards

❌ Do NOT use a card when:
- The content is a **section of a single screen** (e.g., the calorie summary, the macro breakdown). Use section spacing instead.
- The content is a **form or input group**. Inputs live directly on the screen.
- The content is **static metadata** (a label-value pair). Use inline stat patterns.
- The content is a **navigation destination** (a menu item). Use list items.
- Nesting would occur — **a card inside a card is never acceptable**

### 11.4 Card Anatomy

```
┌─────────────────────────────────────┐  ← surface fill, radiusMd
│ lg padding (16px)                   │
│                                     │
│  Title (title typography)           │
│  Subtitle (caption, textSecondary)  │
│                                     │
│  [Content area]                     │
│                                     │
│  Optional action row                │
│ lg padding (16px)                   │
└─────────────────────────────────────┘
```

### 11.5 Card Rules

1. **Maximum one level of cards.** Cards sit on the background. Nothing sits on a card.
2. **Cards in lists have consistent internal structure.** Every card in a list has the same padding, same typography levels, same action position.
3. **Card tap targets are the full card area** unless the card contains multiple independent actions (rare).
4. **Cards do not have visible borders** by default. The surface fill provides distinction. Borders are added only for selected/active states.

---

## 12. Navigation & Information Architecture

### 12.1 Primary Navigation

- **Pattern:** Bottom navigation bar with 4 tabs (current: Home, Workouts, Progress, Nutrition)
- **Bar style:** `background` color fill, thin `divider` top border, 64px height
- **Labels:** Always visible (no icon-only tabs), `caption` typography
- **Active indicator:** `primary` color icon + text, subtle `primaryMuted` background pill
- **Inactive:** `textSecondary` color

### 12.2 Navigation Principles

1. **Maximum 5 bottom tabs.** If more top-level destinations are needed, some must become secondary navigation.
2. **Each tab preserves its own scroll position and state** when switching between tabs (StatefulShellRoute).
3. **Profile/Settings are accessed from a header action** (avatar icon on Home), not a tab.
4. **Within-feature navigation** uses push (detail screens, editors, pickers) with a back arrow.
5. **Modals and bottom sheets** are for quick interactions (confirm, select, edit single values). They do not replace full screens.
6. **Deep links must resolve predictably.** Every screen with a route must render correctly when accessed directly.
7. **Never use horizontal page swiping for navigation between peer sections.** Tabs handle this via the bottom bar.

### 12.3 Transitions

- **Push navigation:** Platform-default slide transition (right-to-left on Android)
- **Modal presentation:** Bottom-to-top slide for bottom sheets, fade for dialogs
- **Tab switch:** Instant (no animation) — the `IndexedStack` pattern
- **Custom transitions:** Only when they communicate a spatial relationship (e.g., expanding a card to a detail view)

---

## 13. Data Visualization

### 13.1 General Rules

1. **Every chart must answer a question.** "How has my bench press progressed?" "Am I hitting my protein goal?" If the chart doesn't answer a clear question, remove it.
2. **Readable at a glance.** The main takeaway should be obvious without reading axes or legends.
3. **Consistent color mapping.** If `primary` represents protein in one chart, it represents protein in every chart.
4. **No 3D effects.** No gradients under chart lines. No drop shadows on bars.
5. **Sensible empty states.** An empty chart shows the axes/structure with a centered "No data yet" message — not a blank void.
6. **Small-screen safe.** Charts must be legible on a 360px-wide phone. Prefer horizontal scrolling for time series over cramming.

### 13.2 Chart Types

| Data Type | Recommended Chart | Notes |
|:---|:---|:---|
| Progress over time (weight lifted, body weight) | Line chart | Thin line (2px), dot markers on data points, `primary` color |
| Daily/weekly comparison | Bar chart | Vertical bars, `primary` fill, `surface` background |
| Goal progress (calories, macros) | Linear progress bar | See §10.8. No pie charts for macro splits. |
| Distribution (muscle group coverage) | Horizontal bar chart | Sorted descending, `primary` fill |
| Consistency (workout frequency) | Simple dot grid / activity heatmap | GitHub-style contribution grid, subtle color scale |

### 13.3 Macro Color Mapping

When macros need distinct colors (e.g., a stacked view):

| Macro | Color | Rationale |
|:---|:---|:---|
| Protein | `primary` | Most important — always emphasized first (§11.9) |
| Carbohydrates | `textSecondary` | Neutral |
| Fat | `textMuted` | Least visual emphasis |

This is **not a red/green/blue scheme.** The palette stays restrained and within the dark theme's color budget.

### 13.4 Number Formatting

| Value | Format | Example |
|:---|:---|:---|
| Weight (kg) | No trailing `.0`, 1 decimal if needed | `80 kg`, `72.5 kg` |
| Calories | Integer, no thousands separator under 10k | `1,847 kcal` or `1847 kcal` |
| Percentage | Integer + `%` | `73%` |
| Duration | `MM:SS` or `H:MM:SS` | `45:30`, `1:12:05` |
| Reps | Integer | `8` |
| Sets | Integer | `4` |
| Volume (weight × reps) | No trailing `.0`, abbreviated if > 10k | `12,500 kg` |

---

## 14. Information Density

### 14.1 Rules

1. **Above the fold: primary purpose only.** The first viewport-height of content should communicate the screen's primary purpose and action. Secondary detail lives below.
2. **Maximum 3 hero metrics per screen.** More than three large numbers creates visual competition. Additional metrics become secondary (stat rows, inline stats).
3. **Group related metrics.** "Duration · Sets · Volume" belong together. Don't scatter related numbers across different sections.
4. **Hide secondary detail by default.** Exercise instructions, historical set data, macro micronutrient breakdowns — these are expandable, not always-visible.
5. **Summary before detail.** A workout card shows "Chest Day · 45min · 24 sets" — not every exercise and set inline. Tap for detail.
6. **Adaptive density.** More items = more compact. A history list with 50 entries should be denser than a routine list with 3.

### 14.2 Dashboard Hierarchy Pattern

For screens that aggregate multiple data sources (Home, Progress, Nutrition Dashboard):

```
1. Hero section (1-2 headline metrics or primary CTA)
2. Status/context bar (streak, active session, day navigation)
3. Primary content section (recent workouts, meal log, PR preview)
4. Secondary content section (less critical — view all links)
```

Each section is separated by `xl` (20px) spacing. Sections are **not individually carded** — they live on the background with section headers.

---

## 15. Forms & Inputs

### 15.1 Field Hierarchy

1. **Primary fields** (required, most-used): Full width, prominent, at the top
2. **Secondary fields** (optional, less-used): Below primary, may be in expandable sections
3. **Advanced fields** (rarely changed): Behind "Advanced" or "More options" disclosure

### 15.2 Validation

- **Inline validation** on field blur (not on every keystroke)
- **Error text** appears below the field in `warning` color, `caption` typography
- **Error border** changes to `warning` color
- **Submit-time validation** catches anything inline validation missed
- **Never block the user from seeing the form** because of a validation error

### 15.3 Fitness-Specific Input Patterns

#### Quick Numeric Entry (Weight/Reps)
For repeatedly entered values (sets during a workout):
- **Stepper buttons** (±2.5 kg, ±1 rep) for quick adjustment
- **Tap on value** opens a focused numeric input dialog
- **Ghost prefill** shows last-performed value as placeholder
- **Hardware keyboard:** Number pad only (`TextInputType.number`)

#### Quantity Selector (Food Servings)
- **Preset chips** (0.5, 1, 1.5, 2) + Custom button
- **Unit dropdown** (household unit, grams)
- **Live macro recalculation** on change

#### Date/Time
- Use platform-native date/time pickers. Do not build custom calendar widgets unless the product specifically requires one.

### 15.4 Save Patterns

- **Auto-save (write-through):** For workout set data — saves immediately on confirmation (Law L7). No save button.
- **Explicit save:** For entity creation/editing (routines, goals, profile). Prominent save button, disabled until changes exist.
- **Destructive actions:** Always behind a confirmation dialog. The dialog states what will be lost. Two-step for permanent deletions.

---

## 16. States — Every Screen Must Handle All

### 16.1 Required States

Every screen and every async data section must account for:

| State | What it looks like |
|:---|:---|
| **Loading** | Skeleton loader matching the expected content shape (§10.14) |
| **Empty** | Icon + factual title + optional action (§10.13). Never blank. |
| **Populated** | Normal content display |
| **Error** | Error icon + message + RETRY action (§10.15). Never a dead end. |
| **Partial data** | Show what's available, indicate what's missing with subtle placeholders |
| **Offline** | Identical to populated — the app is offline-first, so "offline" is the default (Law L2). No special offline indicator. |
| **First-use** | A gentle variant of empty: welcoming but not overwrought. "Start your first workout" — not "Welcome to your fitness journey! 🎉✨" |
| **Disabled** | Reduced opacity, non-interactive, clear visual signal |
| **Success** | Brief, subtle. A snackbar or a state change (button text changes to "Saved ✓"). No modals, no celebrations. |

### 16.2 Rules

1. **Every `AsyncValue.when()` must handle `loading`, `error`, and `data`.** No `.requireValue` without error handling.
2. **Empty checks go inside `data`.** Don't conflate "loaded with zero items" and "loading."
3. **Error messages should be human-readable.** Not stack traces, not error codes. "Couldn't load your workouts. Check your connection and try again."
4. **First-use state is distinct from empty state.** A user who has never logged a workout sees a different message than a user whose search returned zero results.

---

## 17. Motion & Micro-Interactions

### 17.1 Duration Scale

| Token | Duration | Usage |
|:---|:---:|:---|
| `fast` | 100ms | Opacity changes, color transitions, icon swaps |
| `standard` | 200ms | Component expansion/collapse, slide-in elements |
| `slow` | 300ms | Page transitions, bottom sheet entry, complex layout changes |

### 17.2 Curves

- **Default:** `Curves.easeInOut` — for most transitions
- **Entry:** `Curves.easeOut` — elements appearing (sheets sliding up, items fading in)
- **Exit:** `Curves.easeIn` — elements leaving
- **Spring:** Only for pull-to-refresh and overscroll feedback (platform default)

### 17.3 What Gets Motion

✅ **Animate:**
- Page transitions (platform default)
- Bottom sheet entry/exit
- Expandable section height changes
- Progress bar fill changes
- Button state transitions (color, opacity)
- List item additions/removals (when user-initiated)
- Snackbar entry/exit

❌ **Do NOT animate:**
- Individual text changes (no number counting animations)
- Section appearances on page load (no staggered fade-in)
- Card hover/focus (this isn't web)
- Background elements (no ambient motion)
- Skeleton loader shimmer (static skeletons are sufficient)
- PR celebrations beyond a single subtle haptic

### 17.4 Haptic Feedback

- **Medium haptic:** On set completion (✓), PR achievement, destructive action confirmation
- **Light haptic:** On toggle changes, chip selection
- **No haptics:** On normal navigation, scrolling, or text input

### 17.5 Accessibility: Reduced Motion

When the system `MediaQuery.disableAnimations` flag is set:
- All durations become 0ms (instant state changes)
- Transitions become instant cuts
- The UI remains fully functional without any motion

---

## 18. Accessibility

### 18.1 Contrast

- Text on background: Minimum 7:1 ratio (WCAG AAA for normal text)
- `textPrimary` (#FFFFFF) on `background` (#000000): 21:1 ✓
- `textSecondary` (55% white) on `background`: ~11:1 ✓
- `textMuted` (35% white) on `background`: ~7:1 ✓ (minimum threshold — use only for truly tertiary text)
- `primary` on `background`: Verify ≥ 4.5:1 for interactive elements

### 18.2 Tap Targets

- **Minimum:** 44×44px (not 48×48 — but 48×48 preferred for primary actions)
- **Interactive list items:** Full-width tap target
- **Icon buttons:** 40×40px visual, with 44×44px hit test area (padding)
- **Stepper buttons:** 36×36px minimum

### 18.3 Semantic Labels

- Every interactive element has a semantic label or tooltip
- Images have `semanticLabel` descriptions
- Decorative elements are excluded from the semantics tree (`ExcludeSemantics`)
- Custom widgets use `Semantics` widget with appropriate `label`, `button`, `header` roles

### 18.4 Text Scaling

- All text uses `sp` (the default in Flutter) — respects system text scale
- Layouts must not overflow at 1.5× text scale
- Fixed-height containers must become flexible when text scaling is enabled
- Test at 1.0× and 1.5× system text scale

### 18.5 Screen Readers

- Logical focus order follows visual layout (top-to-bottom, left-to-right)
- Group related content with `MergeSemantics` where appropriate
- Stat blocks read as "[Value] [Label]" (e.g., "45 minutes Duration")
- Charts provide text alternatives summarizing the data

### 18.6 Color Independence

- Never convey meaning through color alone. Every colored state (success, error, selected) also has a text label, icon change, or shape change.
- PR badges say "PR" in text, not just a green dot
- Error states have both red color AND an error icon AND error text

---

## 19. Responsive Behavior

### 19.1 Target Devices

- **Primary:** 360-412px width phones (budget Android, ₹9,000 class)
- **Secondary:** 412-430px width phones (mid-range Android)
- **Edge case:** 320px width (very small phones), 600px+ (small tablets)

### 19.2 Rules

1. **Design for 360px width first.** If it works at 360px, it works everywhere.
2. **Horizontal padding is fixed** (`lg` = 16px). Content stretches to fill.
3. **Lists and cards are full-width.** No multi-column card grids on phones.
4. **Stat blocks reflow.** A 4-stat row at 412px may become 2×2 at 320px.
5. **Long text truncates** with ellipsis on single-line displays (exercise names, food names).
6. **Long numbers never truncate.** They are the content. If a number doesn't fit, the layout needs adjustment.
7. **Keyboard-aware.** When the keyboard opens, the focused field must be visible. Use `SingleChildScrollView` with `Scaffold.resizeToAvoidBottomInset`.
8. **Bottom sheets above keyboard.** Sheet content scrolls; the sheet itself sits above the keyboard.
9. **Safe areas always respected.** `SafeArea` on every screen body. Bottom navigation handles its own safe area.

### 19.3 Landscape

- Not a design priority (fitness apps are used one-handed in portrait)
- Content should not break in landscape, but optimized landscape layouts are not required
- Charts may benefit from landscape viewing — allow rotation but don't redesign for it

---

## 20. Content & Microcopy

### 20.1 Voice

The app sounds: **clear, calm, concise, useful, human.**

It does NOT sound: motivational, excited, judgmental, robotic, or corporate.

### 20.2 Rules

| Do | Don't |
|:---|:---|
| "No workouts yet" | "It's empty in here! 😢" |
| "You're on track today" | "You are absolutely CRUSHING your goals! 🔥🔥🔥" |
| "3 of 4 workouts this week" | "Almost there! Just ONE MORE to hit your goal!!!" |
| "Couldn't save. Your data is safe on this device." | "Oops! Something went wrong 😅" |
| "Over target by 150 kcal" | "⚠️ You've exceeded your calorie limit!" |
| "Log food" | "Track your nutrition! 🥗" |
| "Start workout" | "Let's get started! 💪" |

### 20.3 Specific Patterns

- **Button text:** Imperative verbs. "Save", "Start", "Finish", "Log", "Delete". Not "Submit", "Confirm", "OK".
- **Section headers:** Noun phrases, ALL CAPS. "RECENT WORKOUTS", "THIS WEEK", "DAILY TOTALS".
- **Empty states:** Statement of fact + optional action. "No routines yet. Create your first routine."
- **Errors:** What happened + what the user can do. "Couldn't load exercises. Tap retry to try again."
- **Confirmations:** What will happen. "Delete this workout? This can't be undone."
- **Numbers:** Bare values with units. "80 kg", "1,847 kcal", "45:30". No decorative context ("You lifted...").

### 20.4 Nutrition Tone (Law L4)

The nutrition UI is **adherence-neutral**. It presents facts without judgment:
- "Over target" not "Over limit" or "Exceeded"
- No red/green judgment colors on calorie progress
- No celebratory or shaming language about food choices
- The calories-remaining card hides entirely when no goals are set — it doesn't nag

---

## 21. Fitness & Nutrition Product UX

### 21.1 Workout Logging UX

The core action (logging a set) must be completable in **< 3 seconds** (Law L1):
1. See ghost prefill from previous performance
2. Adjust weight/reps if needed (steppers or tap-to-edit)
3. Tap ✓ to confirm

This flow must be:
- **One-handed operable** (phone propped on gym bench)
- **Glanceable** (weight and reps visible at arm's length)
- **Error-recoverable** (un-confirm a set, edit after confirmation)
- **Persistent** (every confirmed set is in SQLite before the UI updates)

### 21.2 Nutrition Logging UX

Food logging should be fast but not careless:
- **Search-first** approach (no browsing categories)
- **Recent items** prominently available (most users eat the same foods)
- **Household units** as the default for Indian foods ("1 katori", not "150g")
- **Quick log from previous meals** (repeat yesterday's breakfast)
- **Inline quantity adjustment** without opening a new screen

### 21.3 Progress UX

Progress should motivate through **clear data**, not through gamification:
- Personal records are celebrated subtly (a badge + one haptic, not confetti)
- Streaks are displayed as neutral facts ("3 weeks"), never shaming ("You broke your streak!")
- Volume trends show direction without judgment
- History is browsable and repeatable

### 21.4 Offline-First UX (Law L2)

- The app must feel identical online and offline
- No "connecting..." states, no sync spinners on primary surfaces
- Sync status lives in Settings/Profile, never on the main dashboard
- Search, logging, history — everything works from SQLite with zero network

### 21.5 General Fitness App Patterns

These patterns should be supported by the design system when their features are implemented:

- Daily overview dashboards
- Goal setting and tracking
- Workout templates and routines
- Exercise libraries with search and filters
- Set/rep/weight logging with prefill
- Rest timers
- Personal record tracking
- Nutrition meal logging
- Macro tracking
- Body measurement tracking
- Historical data browsing
- Streak and consistency tracking
- Progress charts and analytics
- Data import/export
- Personalization and settings

The design system does not assume all of these exist — it provides the visual vocabulary to build any of them consistently.

---

## 22. Anti-AI-Slop Design Rules

This section is **mandatory reading** for every coding agent. AI-generated UI tends toward specific failure modes that must be actively prevented.

### 22.1 Prohibited Patterns

| Pattern | Why it's wrong |
|:---|:---|
| Random gradients | Not in the color system. Adds visual noise. |
| Arbitrary colors outside the defined palette | Violates the restrained color system. |
| Purple/blue "AI aesthetics" | Not our brand. Not our palette. |
| Giant hero sections with minimal content | Wastes prime screen real estate. |
| Heavy glassmorphism (blur, frosted glass) | Was tried. Looked bad on device. Retired. |
| Excessive shadows on every card | OLED dark theme — shadows are invisible and wasteful. |
| Every element wrapped in a Card widget | Cards are for discrete entities, not general containers. See §11. |
| Random decorative shapes / blobs | Violates the decorative element policy. |
| Meaningless icons next to every text | Icons must add information. See §9. |
| Excessive badges and pills on everything | Use badges for meaningful status only. |
| Oversized typography without hierarchy | One display-size element per screen, maximum. |
| Generic stock illustrations in empty states | We use icon + text. No illustrations. |
| Unnecessary emojis in UI text | The app sounds calm and professional. |
| Fake motivational language | "Great job! 🎉" is never appropriate. |
| Inconsistent spacing (random padding values) | Use the spacing scale. Always. |
| Inconsistent corner radii (some 8, some 12, some 20, some 0) | Use the radius scale. One radius per component type. |
| One-off components that duplicate existing patterns | Reuse before creating. |
| Visual changes that exist only to make a screen look "busy" | Restraint is a feature. |
| Copying visual styles from unrelated apps | Our system is self-contained. |
| Staggered entrance animations on page load | Content appears immediately. |
| Number counting animations | Numbers are static text with tabular figures. |
| Shimmer loading effects | Static skeletons. Budget phone performance. |

### 22.2 Positive Rules

| Rule | How to apply it |
|:---|:---|
| Reuse existing components | Before creating anything, check §10. Does a component already exist? |
| Prefer composition over decoration | Build with existing primitives. Don't add visual weight. |
| Use whitespace intentionally | Whitespace is a design tool. Use the spacing scale. |
| Establish hierarchy before styling | Decide what's most important. Then decide what's secondary. Then style. |
| Use one coherent visual language | Everything in this document. Nothing outside it. |
| Favor meaningful patterns | If a pattern appears 3+ times, it should be a shared component. |
| Prefer restraint | When in doubt, use less color, fewer elements, simpler structure. |
| Introduce new patterns only when necessary | The existing system must genuinely fail before a new pattern is justified. |
| Test on 360px width | If it works at 360px, it works everywhere. |
| Read the design system first | Before touching any UI code, read this document. |

### 22.3 The "Remove Test"

Before finalizing any screen, perform this test:

> For every visual element on the screen, ask: "If I removed this, would the screen lose meaning?"

If the answer is no, remove it. The screen is better without it.

---

## 23. Design Decision Framework

When making any UI decision, follow this checklist:

### Before Adding a New Component

1. Does an existing component solve this? (Check §10)
2. Does this exact pattern already exist on another screen?
3. Does this improve clarity for the user?
4. Does it reduce or increase cognitive load?
5. Does it fit the spacing system? (Check §6)
6. Does it fit the typography hierarchy? (Check §5)
7. Does it fit the color system? (Check §4)
8. Is there a strong product reason to introduce a new component?
9. Does it remain accessible? (Check §18)
10. Would this still work if the screen had twice as much data?

### Before Styling a Screen

1. What is the single primary purpose of this screen?
2. What is the primary action?
3. What information must be visible first (above the fold)?
4. What information is secondary (below fold or expandable)?
5. Which existing component patterns apply?
6. Am I using the spacing scale consistently?
7. Am I using the type scale consistently?
8. Does the screen have too much color? (Apply the 85/10/5 rule from §4.2)
9. Is every visual element earning its place? (Apply the Remove Test from §22.3)
10. Does this screen feel consistent with the rest of the app?

---

## 24. Flutter Implementation Guidance

### 24.1 Theme Architecture

```dart
// All design tokens centralized in a single theme class
abstract final class AppTheme {
  // Color tokens (§4)
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  // ... all semantic colors

  // Spacing tokens (§6)
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  // ... full scale

  // Radius tokens (§7)
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // Motion tokens (§17)
  static const Duration motionFast = Duration(milliseconds: 100);
  static const Duration motionStandard = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 300);

  // Typography helpers
  static TextStyle num(double size, {FontWeight weight, Color? color});
  
  // ThemeData builder
  static ThemeData get dark => ThemeData(...);
}
```

### 24.2 ColorScheme Mapping

Map semantic tokens to Flutter's `ColorScheme`:

```dart
ColorScheme.dark(
  primary: primary,        // #00D4AA
  onPrimary: background,   // #000000
  secondary: secondary,    // #C8E640
  onSecondary: background,
  error: warning,          // #E8772E
  onError: background,
  surface: surface,        // #0A0A0A
  onSurface: textPrimary,  // #FFFFFF
)
```

### 24.3 ThemeExtension for Custom Tokens

For tokens not covered by `ColorScheme`, use `ThemeExtension`:

```dart
class AvenFitColors extends ThemeExtension<AvenFitColors> {
  final Color surfaceElevated;
  final Color surfaceActive;
  final Color primaryMuted;
  final Color secondaryMuted;
  final Color warningMuted;
  final Color textMuted;
  final Color border;
  final Color divider;
  // ...
}
```

### 24.4 Implementation Rules

1. **Never hardcode hex colors in widget files.** Always use `AppTheme.tokenName` or `Theme.of(context).colorScheme.property`.
2. **Never hardcode padding values.** Use `AppTheme.spaceLg` or named constants from the spacing scale.
3. **Never hardcode border radii.** Use `AppTheme.radiusMd` or the radius scale.
4. **Never hardcode text styles inline.** Use the theme's `textTheme` or `AppTheme.num()` for numeric displays.
5. **Reusable widgets live in `core/widgets/` or `features/<feature>/presentation/widgets/`.** If a widget is used by 2+ features, it goes in `core/widgets/`.
6. **Component widgets are configurable via parameters**, not via conditional styling branches. A card widget accepts a `title`, `subtitle`, and `trailing` — it doesn't check what screen it's on.
7. **Use `const` constructors** wherever possible for widget performance.
8. **Avoid `Container`** when `Padding`, `DecoratedBox`, `SizedBox`, or `ColoredBox` suffice. Container is a convenience wrapper — be explicit.

### 24.5 Shared Widget Library

Maintain these canonical shared widgets in `core/widgets/`:

| Widget | Purpose |
|:---|:---|
| `EmptyStateWidget` | Icon + title + optional message + optional action |
| `LoadingStateWidget` | Skeleton loader with configurable row count |
| `ErrorStateWidget` | Error display with RETRY action |
| `StatBlock` | Hero/standard/inline stat display |
| `SectionHeader` | ALL CAPS label with optional trailing action |
| `ActionCard` | Tappable card with title, subtitle, trailing |
| `StepperInput` | ±buttons + value display + tap-to-edit |
| `ConfirmDialog` | Standard confirmation with cancel/confirm |

New shared widgets follow the same pattern: configurable via constructor parameters, internally styled from the theme, no business logic.

---

## 25. Design Tokens — Complete Reference

### 25.1 Colors

```
── Background ──────────────────────────────
background          #000000
surface             #0A0A0A
surfaceElevated     #141414
surfaceActive       #1A1A1A

── Brand ───────────────────────────────────
primary             #00D4AA
primaryMuted        #00D4AA @ 15%
secondary           #C8E640
secondaryMuted      #C8E640 @ 15%
warning             #E8772E
warningMuted        #E8772E @ 15%

── Text ────────────────────────────────────
textPrimary         #FFFFFF
textSecondary       #FFFFFF @ 55%
textMuted           #FFFFFF @ 35%
textOnPrimary       #000000

── Structural ──────────────────────────────
border              #FFFFFF @ 8%
borderFocused       primary
divider             #FFFFFF @ 6%
disabled            #FFFFFF @ 20%
overlay             #000000 @ 60%
```

### 25.2 Typography

```
── Scale ───────────────────────────────────
display             Inter 28/700/-0.5/1.2
heading             Inter 20/700/-0.3/1.3
title               Inter 16/600/0/1.4
body                Inter 14/400/0/1.5
bodyMedium          Inter 14/500/0/1.5
label               Inter 12/600/0.3/1.3
caption             Inter 11/500/0.2/1.3

── Numeric ─────────────────────────────────
numHero             JetBrains Mono 28-32/700 (tabular)
numPrimary          JetBrains Mono 18-20/600 (tabular)
numInline           JetBrains Mono 14-16/500 (tabular)
numSecondary        JetBrains Mono 12-13/500 (tabular)
numMicro            JetBrains Mono 10-11/600 (tabular)
```

### 25.3 Spacing

```
xxs     2px
xs      4px
sm      8px
md      12px
lg      16px
xl      20px
xxl     24px
xxxl    32px
```

### 25.4 Radius

```
radiusSm    8px     Buttons, inputs, chips
radiusMd    12px    Cards, containers, dialogs
radiusLg    16px    Bottom sheets (top corners)
radiusFull  999px   Badges, tags, avatars
```

### 25.5 Elevation

```
Level 0     background (#000000)
Level 1     surface (#0A0A0A)
Level 2     surfaceElevated (#141414)
Level 3     overlay (scrim + surfaceElevated)
```

### 25.6 Motion

```
fast        100ms   easeInOut
standard    200ms   easeInOut
slow        300ms   easeOut (entry) / easeIn (exit)
```

### 25.7 Sizes

```
── Controls ────────────────────────────────
buttonHeight        48px
chipHeight          32px
inputHeight         48px
iconButtonSize      40px (visual), 44px (hit test)
navBarHeight        64px
stepperButtonSize   36px

── Icons ───────────────────────────────────
iconNav             22px
iconAction          20px
iconSection         18px
iconSmall           16px
iconBadge           14px
iconEmpty           28px
```

---

## 26. Screen Design Process

When designing or redesigning any screen, follow this process. Do NOT skip steps.

### Step 1: Purpose
Identify the single primary purpose of the screen. Write it in one sentence.

### Step 2: Primary Action
Identify the primary action the user should take. There is only one.

### Step 3: Essential Information
List the information that must be visible above the fold. Be ruthless — most things are secondary.

### Step 4: Hierarchy
Rank the information. What's most important? What's secondary? What's hidden/expandable?

### Step 5: Layout Pattern
Choose from existing layout patterns:
- **Dashboard:** Hero stat + sections (Home, Nutrition Dashboard)
- **List:** Section header + scrollable items (History, Exercises, Routines)
- **Detail:** Header + content blocks + bottom action (Workout Detail, Food Detail)
- **Editor:** Form fields + sticky bottom action (Routine Editor, Goal Settings)
- **Active Session:** Sticky header/timer + scrollable content + sticky bottom actions (Active Workout)

### Step 6: Existing Components
Map every element to an existing component from §10. If a component doesn't exist, check if an existing one can be parameterized to fit.

### Step 7: New Components (Only if Necessary)
If a genuinely new component is needed, design it following the token system and add it to the shared widget library.

### Step 8: States
Design all states: loading, empty, populated, error, first-use. Not as afterthoughts — as part of the initial design.

### Step 9: Verify
Run through the Design Review Checklist (§27).

---

## 27. Design Review Checklist

Before considering any screen implementation complete, verify every item:

### Visual Consistency
- [ ] All colors from the semantic color system (§4)
- [ ] All typography from the type scale (§5)
- [ ] All spacing from the spacing scale (§6)
- [ ] All radii from the radius scale (§7)
- [ ] No hardcoded hex values, pixel values, or text styles in widget code

### Hierarchy & Clarity
- [ ] Clear primary purpose — can state it in one sentence
- [ ] Clear primary action — one primary button maximum
- [ ] Information hierarchy — most important content dominates visually
- [ ] Hero metrics limited to 3 maximum per screen
- [ ] Secondary information is below fold or expandable

### Components
- [ ] All elements use existing component patterns from §10
- [ ] No duplicate visual patterns that should be shared widgets
- [ ] Cards used only for discrete entities (§11)
- [ ] No cards nested inside cards

### States
- [ ] Loading state with skeleton loader
- [ ] Empty state with icon + text + optional action
- [ ] Error state with message + RETRY
- [ ] Success feedback (subtle — snackbar or state change)
- [ ] Disabled states are visually distinct

### Accessibility
- [ ] Contrast ratios meet minimums (§18.1)
- [ ] Tap targets ≥ 44px (§18.2)
- [ ] Semantic labels on all interactive elements
- [ ] Layout doesn't overflow at 1.5× text scale
- [ ] Color is never the sole indicator of meaning

### Responsive
- [ ] Works at 360px width
- [ ] Long text truncates gracefully
- [ ] Numbers never truncate
- [ ] Keyboard doesn't obscure active input

### Content
- [ ] Text tone is calm, factual, concise (§20)
- [ ] No motivational gimmicks, emojis, or fake enthusiasm
- [ ] Nutrition language is adherence-neutral (Law L4)
- [ ] Error messages have recovery guidance

### AI-Slop Check
- [ ] No random gradients or decorative elements
- [ ] No excessive color (85/10/5 rule)
- [ ] No excessive glassmorphism, glow, or shadow
- [ ] No oversized typography without clear hierarchy
- [ ] No unnecessary icons or badges
- [ ] No staggered entrance animations
- [ ] Remove Test applied — every element earns its place

### Motion
- [ ] Transitions use the motion token scale (§17.1)
- [ ] No decorative animations
- [ ] Reduced motion preference respected
- [ ] Haptic feedback used appropriately and sparingly

---

## Appendix A: Migration from v1 Design

The previous "Sharp Glassmorphism" design system (documented in ARCHITECTURE.md and the original `app_theme.dart`) is **retired**. Key changes:

| v1 (Sharp Glassmorphism) | v2 (This Document) |
|:---|:---|
| Zero border radius (sharp edges) | Soft rounded corners (8/12/16px) |
| Neon cyan `#00F0FF` | Calmer teal `#00D4AA` |
| Electric volt green `#E2F835` | Softer yellow-green `#C8E640` |
| Harsh burnt orange `#E85D04` | Warmer amber `#E8772E` |
| Glass fill (`#FFFFFF` at 4%) + glass border everywhere | Solid subtle fills (`#0A0A0A`) with minimal borders |
| `AppTheme.glassFill` / `AppTheme.glassBorder` | `AppTheme.surface` / `AppTheme.border` |
| Borders on every container | Borders only on inputs and selected states |
| No spacing system | Defined 4px-based spacing scale |
| No radius system | Defined 4-level radius scale |
| No surface hierarchy | 3-level surface hierarchy (background/surface/elevated) |

When updating existing screens:
1. Replace `AppTheme.glassFill` → `AppTheme.surface`
2. Replace `AppTheme.glassBorder` → `AppTheme.border` (and remove most border usages)
3. Replace `BorderRadius.zero` → `BorderRadius.circular(AppTheme.radiusMd)` (or appropriate level)
4. Replace `AppTheme.neonCyan` → `AppTheme.primary`
5. Replace `AppTheme.voltGreen` → `AppTheme.secondary`
6. Replace `AppTheme.burntOrange` → `AppTheme.warning`
7. Review and apply the spacing scale to all padding/margin values

---

## Appendix B: Reference Applications

For visual calibration, these apps represent the **general aesthetic direction** (not to be copied, but to understand the level of quality and restraint expected):

- **Oura Ring** — Clean data presentation, dark theme, restrained color, premium feel
- **Whoop** — Data-forward, dark, typographic, minimal decoration
- **Apple Health** — Clear hierarchy, meaningful whitespace, restrained charts
- **Strong (workout tracker)** — Functional, fast set logging, no visual noise
- **Bear (notes app)** — Typographic excellence, minimal UI chrome, calm

These are NOT reference applications:
- MyFitnessPal (cluttered, ad-heavy)
- Fitbit (gamification-heavy)
- Duolingo (mascot/gamification)
- Any app with gradients, glow effects, or heavy illustration

---

*End of design system specification.*
