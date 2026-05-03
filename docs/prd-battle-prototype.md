# PRD: Battle Prototype (Vertical Slice)

## Problem Statement

There is no playable game yet. The concept calls for a Slay the Spire–style roguelike deckbuilder themed around goblins, but before any of that scope makes sense to build, we need proof that the core deckbuilder combat loop works in Godot, feels right (specifically the StS2 hand and card UI feel), and rests on architecture that won't have to be thrown away when content scales up.

## Solution

Build a single, fully playable battle that exercises the entire deckbuilder loop end-to-end:

- One playable character (Goblin) on the left, two distinct goblin enemies on the right.
- A starter deck of 10 cards (5 Strike, 4 Defend, 1 Poison Dart) with 3-energy turns and 5-card draws.
- A fanned hand with hover, drag-to-play, and drag-to-target interactions matching the StS2 feel.
- Enemy intent displayed before each player turn so plays can be planned.
- Six effect types (Damage, Shield, Draw, Poison, Create Card, Discard) and two persistent statuses (Poison, Shield), each implemented as composable Resources.
- A unified event-bus architecture supporting both pure notifications and mutable pipelines, so future modifiers (Strength, Vulnerable, etc.) and new content can be added without rewriting the rules engine.
- Win/lose feedback with a restart button, so the loop is iterable for testing.

The output is a single battle the developer can play repeatedly to validate that the architecture supports the eventual full game, and that the moment-to-moment interaction feels like a Slay the Spire 2 battle.

## User Stories

### Player — battle setup and orientation

1. As a player, I want to start a single combat encounter immediately when the project runs, so that I can experience the core gameplay without navigating menus.
2. As a player, I want to see my Goblin character on the left side of the screen with their HP, so that I know who I'm playing as.
3. As a player, I want to see two distinct goblin enemies on the right side of the screen, so that I have multiple targets to consider.
4. As a player, I want to see each enemy's intended next action displayed above them, so that I can plan my turn around what's coming.
5. As a player, I want to see both numeric HP and a HP bar on each character, so that I have both a precise and glanceable reading of health.
6. As a player, I want to see status badges (Poison, Shield) below each affected character with stack counts, so that I can track conditions at a glance.

### Player — hand and cards

7. As a player, I want to start each turn with 5 cards drawn from my deck, so that I have options to play.
8. As a player, I want to start each turn with 3 energy refreshed, so that I can decide which cards to play within a budget.
9. As a player, I want to see my hand fanned out on an arc at the bottom of the screen, so that I can read each card clearly.
10. As a player, I want my hand to spread tighter as more cards are added (up to a 10-card cap), so that all cards remain visible even when full.
11. As a player, I want to hover a card to see it lift, scale up, and straighten, so that I can read it more clearly.
12. As a player, I want neighboring cards to slide aside slightly when I hover one, so that the hovered card has visual room.
13. As a player, I want cards I cannot afford to be visually distinguished, so that I don't waste a play attempt.
14. As a player, I want clicks (mouse-down with no movement) on cards to do nothing, so that only deliberate drags commit a play.

### Player — playing cards

15. As a player, I want to drag a target-required card upward and have the card snap to a fixed stage position with an arrow extending to my cursor, so that I can clearly pick which enemy to hit.
16. As a player, I want the targeting arrow to change color when over a valid enemy, so that I know my play will land.
17. As a player, I want to release the card on an enemy to play it, so that the action commits naturally.
18. As a player, I want to release the card off-target to cancel the play and have the card return to my hand, so that I can change my mind without penalty.
19. As a player, I want to drag a non-targeted card upward past a threshold to commit it, so that defensive cards have a clear play motion.
20. As a player, I want to release a non-targeted card below the threshold to cancel, so that I can also change my mind on those.
21. As a player, I want playing a card to deduct its cost from my energy immediately, so that I have to budget choices.

### Player — card effects

22. As a player, I want to play Strike to deal damage to a chosen enemy, so that I can attack.
23. As a player, I want to play Defend to gain shield on myself, so that I can mitigate incoming damage.
24. As a player, I want to play Poison Dart to deal damage and apply poison stacks to a chosen enemy, so that I have a damage-over-time option.
25. As a player, I want shield to absorb incoming damage before it hits HP, so that defense actually matters.
26. As a player, I want shield to disappear at the start of each of my turns, so that defense is reactive, not permanent.
27. As a player, I want poison on a character to tick damage at the end of each turn and decrement a stack, so that the DoT mechanic plays out.

### Player — turn flow and enemies

28. As a player, I want to end my turn with a button click or by pressing Space, so that turn handover is fast.
29. As a player, I want the End Turn button to be disabled while animations are mid-flight or it's the enemy's turn, so that I can't double-trigger turn end.
30. As a player, I want my remaining hand to discard at the end of my turn, so that I'm not stockpiling indefinitely.
31. As a player, I want enemy actions to resolve sequentially after I end my turn, so that I can follow what happens.
32. As a player, I want the Goblin Brute to attack me for 6 damage most turns and gain 5 shield occasionally (weighted random), so that I face a mix of offense and defense.
33. As a player, I want the Goblin Trickster to follow a predictable 3-turn pattern (Throw Dagger → Quick Step → Setup, repeat), so that pattern recognition matters.
34. As a player, I want enemy intent to update visibly each turn, so that I'm never surprised by what enemies will do.
35. As a player, I want defeated enemies to be removed from play, so that I can no longer target them.

### Player — piles and deck cycling

36. As a player, I want to see deck count in the lower-left, discard count in the lower-right, and exhaust count above the discard (only when non-zero), so that I can monitor my deck cycling.
37. As a player, I want to click a pile button to open a modal showing the cards in that pile with a close button, so that I can plan my next turn around what's coming.
38. As a player, I want my draw pile to reshuffle from the discard automatically when emptied, so that the deck cycles naturally.

### Player — outcomes and presentation

39. As a player, I want victory text and a restart button to appear when both enemies are defeated, so that I can play again.
40. As a player, I want defeat text and a restart button to appear when my HP reaches zero, so that I get clear feedback on losing.
41. As a player, I want the battle to end as soon as the win/lose condition is met (even mid-effect-resolution), so that I'm not forced to watch redundant resolutions.
42. As a player, I want all card movements (draw, play, discard, exhaust, reshuffle) to animate smoothly, so that I can follow what's happening.
43. As a player, I want my energy display to update immediately when I play a card, so that I see the cost taken.
44. As a player, I want the End Turn button positioned middle-right above the hand area, so that it falls near where my hand naturally rests.

### Developer — architecture and extensibility

45. As a developer, I want all rules logic to live in node-free RefCounted/Resource code, so that I can test it headlessly without scene instantiation.
46. As a developer, I want a unified event bus that supports both mutable pipelines and pure notifications, so that future modifiers (Strength, Vulnerable, etc.) can be added without rewriting damage code.
47. As a developer, I want pipelines and notifications to share a single mental model (notifications are pipelines with no modifiers), so that there's only one event-handling code path to learn.
48. As a developer, I want events to be passed as mutable typed objects via Godot signals, so that I keep Godot's signal lifecycle ergonomics while gaining mutation semantics.
49. As a developer, I want CardEffect to be a Resource subclass hierarchy where each subclass implements an `apply` method, so that new effects can be added by writing a new class without touching the card system.
50. As a developer, I want to author cards as `.tres` files with `@export` fields, so that I can add new content from the editor without code.
51. As a developer, I want each card to declare a single `target_type` enum (the player's drag target), and each effect to declare its own `affects` scope (SELECTED_TARGET, SELF, ALL_ENEMIES, etc.), so that effects compose without per-card target plumbing.
52. As a developer, I want CardData (template) and CardInstance (runtime) split, so that runtime modifications, upgrades, and per-instance state don't pollute the template.
53. As a developer, I want statuses to share the template/instance pattern with cards (StatusData + StatusInstance), so that the rules engine has consistent vocabulary.
54. As a developer, I want Shield modeled as a status (not a special integer field), so that the status system is exercised uniformly and Shield interacts with the damage pipeline naturally.
55. As a developer, I want enemies to use the same CardEffect Resources as cards, so that there's no parallel hierarchy for "enemy actions."
56. As a developer, I want move pickers to be swappable strategy Resources (WeightedRandom, Sequence), so that adding a new enemy AI behavior is a new Resource, not a fork in existing code.
57. As a developer, I want the battle orchestrator to be a single async coroutine that awaits animations between actions, so that the turn flow reads top-to-bottom in time order.
58. As a developer, I want all event subscriptions tied to lifecycle methods (CardInstance.entered_hand/left_hand, StatusInstance.attach/detach), so that subscriptions never leak across zones or battles.
59. As a developer, I want GUT installed and runnable from CLI from day one, so that I can run tests in fast feedback loops and practice TDD.
60. As a developer, I want the project organized with rules code in `core/`, data in `content/`, and scenes in `ui/`, so that the separation between rules and presentation is enforced by structure.
61. As a developer, I want strict typing enabled project-wide, so that type errors are caught at edit time.
62. As a developer, I want the per-battle event bus to be a child node of the battle controller (not an autoload), so that subscribers are auto-cleaned when the battle scene is freed.
63. As a developer, I want Player and Enemy view nodes to be pure visualization that listens to events and reads from BattleState, so that there's no two-sources-of-truth bug between sprite state and rules state.

## Implementation Decisions

### Scope

- **Vertical-slice MVP**: one battle, polished to feel right, architected to extend but not yet content-rich.
- **Visual reference**: Slay the Spire 2 specifically for hand/card UI feel and animations. Mechanics are generic Slay-the-Spire-like, not StS2-specific (no Edges, no fractional energy).
- **Placeholder art tier**: Tier 1 — colored rounded rectangles with text labels for cards, characters, and status badges. No real art assets. Upgrade later.

### Language and tooling

- **GDScript** with strict typing enabled project-wide.
- **Godot 4.6** (already configured).
- **GUT** (Godot Unit Test) installed as a plugin from day one. Tests runnable via CLI for fast feedback loops.

### Folder structure

- `core/` — pure rules code (RefCounted/Resource, no scene-tree dependencies). Subfolders: `battle/`, `cards/`, `effects/`, `characters/`, `enemies/`, `statuses/`.
- `content/` — `.tres` data files only. Subfolders: `cards/`, `enemies/`, `statuses/`.
- `ui/` — all scenes and view-layer scripts. Subfolders: `battle/`, `shared/`.
- `tests/` — mirrors `core/` structure.
- `addons/gut/` — GUT plugin, committed.

### Event bus and pipelines

- One unified event bus (`BattleEvents`) lives as a child Node of the battle controller (per-battle scope; dies when battle ends).
- Events are passed as mutable typed objects (each event class is a `RefCounted` subclass) via Godot signals, preserving Godot's signal lifecycle ergonomics while supporting mid-flight mutation.
- Pipeline is the primary primitive; pure notifications are expressed as a pipeline with no modifiers plus a final notification emit. One mental model, one code path.
- Subscribers register with priority. Pipeline subscribers can mutate the event payload; cancellation via `event.cancelled = true`.
- All subscriptions tied to lifecycle (CardInstance enter/leave hand, StatusInstance attach/detach). No autoload bus.

### Card model

- **CardData (Resource)**: template with `name`, `cost`, `target_type` (ENEMY/SELF/ALL_ENEMIES/NONE), `effects: Array[CardEffect]`, art reference.
- **CardInstance (RefCounted)**: runtime wrapper holding a CardData reference plus mutable state (zone, upgraded flag, runtime modifiers, active subscriptions). Manages subscribe-on-enter-hand / unsubscribe-on-leave-hand.
- **CardEffect (Resource subclasses)**: each effect (Damage, Shield, Poison, Draw, CreateCard, Discard) has `affects: TargetScope` (default SELECTED_TARGET) and `trigger: Trigger` (default PLAY) fields, plus an `apply(battle, source, selected_target)` method. Composable atoms.
- Card is described entirely by its CardData Resource — adding a new card is a new `.tres` file plus zero code (assuming existing effect types suffice).

### Status model

- **StatusData (Resource)**: name, icon, decay rules (`decay_per_turn`, `decay_trigger`), stacking rule.
- **StatusInstance (RefCounted)**: holds StatusData reference plus current stack count and active subscriptions. `attach(character, battle)` subscribes to relevant events; `detach()` unsubscribes.
- Shield is modeled as a status (not a special field), with `decay_trigger = START_OF_OWNER_TURN` and damage-pipeline subscription that absorbs damage by reducing stacks.
- Poison subscribes to `turn_ended`, ticks damage equal to current stacks, decrements one stack.

### Battle state and orchestration

- **BattleState (RefCounted)**: owns deck, hand, discard, exhaust piles (each `Array[CardInstance]`); player and enemies; energy current/max; turn counter; win/lose check.
- **BattleController (Node)**: orchestrator. `run_battle()` async coroutine handles turn flow top-to-bottom: emit `battle_started` → loop (player turn → check end → enemy turn → check end) → emit `battle_ended`.
- **Player and Enemy view nodes**: pure visualization. Listen to events, read `BattleState`. Never mutate state.
- Win/lose check runs after every effect resolves, not just between turns. The orchestrator coroutine breaks out of the turn loop as soon as battle is over.

### Enemy AI

- **EnemyData (Resource)**: `max_hp`, `moves: Array[EnemyMove]`, `move_picker: MovePicker`.
- **EnemyMove (Resource)**: an Intent (icon enum + display value) plus an `Array[CardEffect]` to execute. Reuses the same effect Resources as player cards.
- **MovePicker (Resource subclasses)**: `WeightedRandomPicker`, `SequencePicker`. Selected move is stored on the enemy as `next_move` for intent display, executed on the enemy's turn, then a new move is picked for next turn.

### Two enemies for the prototype

- **Goblin Brute**: 18 HP. WeightedRandomPicker. 70% Smash (6 damage to player), 30% Brace (gain 5 shield).
- **Goblin Trickster**: 12 HP. SequencePicker cycling: Throw Dagger (4 damage) → Quick Step (3 damage + gain 4 shield) → Setup (gain 6 shield).

### Hand UI and interaction

- **HandLayout**: pure function `compute_layout(hand_size, hovered_index, dragged_index, params) → Array[Transform2D]`. Arc-based fan, density scales with hand size, hover lifts the focused card and displaces neighbors. All tunable via `@export` parameters on the HandUI node.
- Cards tween to layout-computed transforms whenever the hand changes (size, hover, drag). Tween duration ~0.18s, ease-out cubic.
- **Drag interaction**: two distinct modes by card target type.
  - Targeted cards: card snaps to fixed stage position above the hand on drag, Line2D arrow extends from card to cursor with a Sprite2D arrowhead, arrow color shifts when hovering a valid enemy. Release on enemy plays; release elsewhere cancels.
  - Non-targeted cards: card lifts and follows cursor on drag; release above a threshold line plays; below cancels.
- Click-without-drag is a no-op.

### Animation strategy

- All animations via Godot's `Tween` (programmatic). No `AnimationPlayer` for MVP.
- Game logic awaits animation completion between discrete actions. Effect Resources mutate state and return synchronously; the orchestrator awaits animation between effects.

### Turn economy

- Hand size: draw to 5 at start of each player turn. Hard cap at 10.
- Energy: 3 per turn, refreshed at start of player turn (no carry-over).
- End of player turn: discard remaining hand to discard pile. Cards with retain (none in MVP) would persist.
- Draw pile reshuffles from discard pile when empty.
- Exhaust pile: per-combat removal (cleared between battles, but MVP only has one battle).

### Starter deck

- 5 × Strike (1 energy, 6 damage to enemy)
- 4 × Defend (1 energy, gain 5 shield to self)
- 1 × Poison Dart (1 energy, 3 damage + apply 2 poison to enemy)

### UI layout

- Player and HP/status badges: top-left.
- Enemies and their HP/intent/status: top-right.
- Hand fan: bottom-center, on an arc.
- Deck pile button: lower-left corner.
- Discard pile button: lower-right corner.
- Exhaust pile button: above Discard (visible only when count > 0).
- Energy orb: bottom-far-right beside Discard.
- End Turn button: middle-right, above the hand area.
- Pile viewer modal: opened on pile-button click, grid of card visuals with close button.
- Win/lose overlay: centered text + restart button, hidden until battle ends.

## Testing Decisions

### What makes a good test

- Tests assert **external behavior** — the publicly observable result of calling a module's interface — not internal implementation details.
- A test should still pass after the module is refactored, as long as the contract is preserved.
- Tests construct minimal scenarios (a tiny `BattleState`, a single CardInstance, a known StatusInstance) and assert specific state mutations or returned values.
- For the event bus, tests should construct an event, register subscribers in known order, and assert mutation/cancellation behavior.
- For pure functions like `HandLayout.compute_layout`, tests should assert specific transform values for specific inputs (e.g., "with 5 cards and no hover, the middle card sits at angle 0").
- UI tests, if attempted, exercise *behavior* (does the layout compute change when hovered_index changes), not *appearance*.

### Modules tested from day one

All deep modules:

1. **BattleEvents** — pipeline ordering, mutation propagation, cancellation, notification fan-out, lifecycle/cleanup of subscribers.
2. **BattleState** — zone movement (deck → hand → discard → exhaust), reshuffle on empty draw, hand cap, energy spend/refresh, win/lose detection.
3. **CardInstance** — attach/detach lifecycle, subscription registration on entering hand, can-play check against energy, play resolution iterates effects.
4. **CardEffect subclasses** — each effect's `apply` produces the expected state change for each `affects` scope (DamageEffect against SELECTED_TARGET, against ALL_ENEMIES; ShieldEffect against SELF; PoisonEffect adding stacks correctly; DrawEffect drawing N cards respecting cap and reshuffle; etc.).
5. **StatusInstance** — Poison subscribes to turn_ended and ticks/decrements correctly; Shield subscribes to damage pipeline and absorbs damage in priority order; both detach cleanly.
6. **MovePicker subclasses** — WeightedRandomPicker honors weights over many trials; SequencePicker cycles deterministically.
7. **HandLayout** — pure function tested with many hand sizes and hover/drag states.

UI views (CardView, HandUI, TargetArrow, etc.) tested by hand initially. The TDD-everything posture is the developer's stated preference, and UI testing will be attempted; it can be dropped if it proves too high-friction for the MVP timeline.

### Prior art

This is a fresh repo with no existing tests. The first test file written will set the convention for the rest. Suggested first test target: `BattleState` zone movement, since it's pure data and the behavior is unambiguous.

## Out of Scope

The following are explicitly excluded from this PRD. Architecture choices preserve the option to add them later, but they are not built in the MVP.

- **Map / run structure** — only one hardcoded battle.
- **Multiple playable characters** — only the Goblin.
- **Card upgrades** — `CardInstance.upgraded` flag exists architecturally but no upgraded card variants are authored.
- **Card rewards / deck editing between battles** — there is no "between battles."
- **Persistence across battles** — no save/load, no progression.
- **Relics / artifacts / persistent passives** — supportable by the event bus, not authored.
- **Damage modifiers** (Strength, Vulnerable, Weak, Intangible) — pipeline architecture supports them, but no statuses or effects in the MVP use them.
- **Multi-target / mixed-target cards** — only one drag target per card.
- **Cards with mid-resolution choices** (Discovery, draft, etc.).
- **Permanent deck removal** outside Exhaust (which clears at battle end anyway).
- **Tooltips** on status badges or cards.
- **Audio** — no sound effects or music.
- **Settings menu, options, key rebinding, localization, accessibility.**
- **AnimationPlayer-driven sprite animations** — Tween only.
- **Real character sprites or finished card art** — Tier 1 placeholder only.
- **Main menu** — the battle scene is the entire game.

## Further Notes

- The "removed pile" mentioned in `concept.md` is interpreted as Exhaust (per-combat removal).
- StS2 is the visual/feel reference for hand and card UI. Mechanics are generic Slay-the-Spire-like — no Edges, no fractional energy, no StS2-specific systems. This decoupling means the prototype can match StS2's *feel* without committing to a moving target on mechanics.
- The event-bus pipeline architecture is the most consequential decision in the PRD. It is the single piece of infrastructure that the entire content system rides on, and the reason the MVP can later absorb modifiers, relics, and new statuses without rewriting damage and turn code. Even though MVP content does not strictly require the pipeline (no current effect mutates another's output), the pipeline is built from day one.
- TDD is the chosen development style. The architectural choice to keep `core/` node-free is what makes this practical — every deep module can be exercised without scene instantiation.
- Tier 1 placeholder art is a deliberate tradeoff against feel polish. The hand fan, hover, and drag interactions will look correct enough with rectangles to validate the math, but the *aesthetic* judgment of "does this feel like StS2" should be deferred to a Tier 2/3 art pass after mechanics are proven.
- Suggested implementation order once this PRD is approved:
  1. Set up GUT, strict typing, folder structure, enums.
  2. BattleEvents pipeline primitive + first test.
  3. BattleState + zone movement + tests.
  4. CardData/CardInstance + first effect (Damage) + test.
  5. Remaining effects + tests.
  6. StatusInstance + Poison and Shield + tests.
  7. EnemyData + MovePickers + tests.
  8. BattleController.run_battle coroutine.
  9. UI scaffolding (player/enemy views, energy, HP, intent display).
  10. HandLayout pure function + tests.
  11. HandUI scene + card tweens.
  12. Drag interaction (both modes) + TargetArrow.
  13. Pile UI + viewer modal.
  14. Win/lose overlay.
  15. Tune feel against StS2 reference.
