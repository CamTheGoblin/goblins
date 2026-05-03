# GOBLINS!! Concept
## Concept Summary
A roguelike deck builder game similar to slay the spire 2 but themed with goblins and other fantasy creatures exploring a dungeon to find their way out. Built in Godot.

## Mechanics
Roguelike deck builder mechanics that work like Slay the Spire 2

## Initial Prototype Goals
- Single playable character to start with, Goblin
- use basic placeholder art elements for things.
- basic card playing mechanics
  - deck
  - drawing cards for turn
  - discard pile
  - removed pile
  - playing cards
  - Hand should be fanned out like it is in slay the spire 2  
  - smooth animation for cards being drawn, played, discarded, removed etc.
  - mouseover focus and click and drag for playing. 
  - match slay the spire 2 ui for card hand exactly
- basic card elements and triggers
  - Cost
  - effects
    - triggers: Play, Draw, Discard, End of turn in hand (modular to allow for additional triggers later)
    - effect types: Damage, Sheild, Draw Card, Poison, Create Card, Discard Card, (modular to allow for additional effects later)
  - 
- Single battle to test out mechanics with
- battle mechanics
  - Start of battle 
  - player character on left, enemies characters on right
  - display character HP and effects icons bellow them
  - show enemy intent above them
  - player takes turn then enemy.
  - player has 3 energy for playing cards
  - Allow for triggers at stages of battle: start of combat, start of player turn. on card play, on card discard, on energy spend, on card draw, on damage dealt, on damage taken, on sheild gained, on turn end, on enemy turn start, on enemy turn end etc. make modular so it can be added to later as needed)
