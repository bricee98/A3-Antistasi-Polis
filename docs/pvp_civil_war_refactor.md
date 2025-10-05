# Civil War PvP Refactor Overview

This document outlines the architectural and gameplay changes required to transform Antistasi into a two-player civil war between NATO and CSAT while keeping AAF and FIA under AI control. The goal is to reuse as much of the existing mechanics as possible while splitting the gameplay loop into two symmetric player-run factions.

## Design Goals

1. **Two-player command structure** – Give both NATO (west) and CSAT (east) human commanders with equivalent strategic tools.
2. **Independent economies** – Maintain distinct HR, manpower, and resource pools per faction, preventing cross-side leakage.
3. **Dual headquarters** – Provide movable HQs and base building systems for both commanders, leveraging existing HQ mechanics where possible.
4. **AI-controlled rebels and government** – Leave FIA and AAF operating via existing AI automation, focusing development time on NATO/CSAT parity.
5. **Minimal disruption of templates** – Reuse current faction templates and logistic structures, keeping backwards compatibility with save data where feasible.

## Architecture Changes

### 1. Side-agnostic Commander Registry

* Introduce a `missionNamespace` hash map (e.g. `A3A_commandStructures`) keyed by side (`west`, `east`, `independent`, `resistance`, etc.).
* Each entry holds commander unit references, HQ position/object IDs, resource/HR pools, unlock progress, and logistic queues.
* Provide helper functions:
  * `A3A_fnc_getCommanderForSide` – returns the commander object (or `objNull`).
  * `A3A_fnc_setCommanderForSide` – handles transfers, HC syncing, and public variables.
  * `A3A_fnc_getEconomyForSide` / `A3A_fnc_updateEconomyForSide` – wrap existing economy helpers but operating on hash map entries.

This allows reuse of existing FIA-centric code paths by passing `sideLogic` data instead of relying on the global `theBoss` variables.

### 2. New Game Mode: Civil War (PvP)

* Extend `Params.hpp`, lobby description strings, and the setup dialog with a "Civil War" option (e.g. `gameMode = 5`).
* In `fn_initServer.sqf`, branch when `gameMode == 5` to:
  * Spawn NATO and CSAT HQ structures using copies of the rebel HQ building functions, but keyed to each side’s entry in `A3A_commandStructures`.
  * Disable FIA player slots or convert them into AI garrisons by default.
  * Call a new initializer `A3A_fnc_initCivilWarMode` that sets default aggression, economy baselines, and AI automation for AAF/FIA.

### 3. Claiming Command & Player Flow

* Add use actions to the NATO and CSAT HQ flags/crates allowing players to claim or hand off command.
* Reuse `fn_makePlayerBossIfEligible` logic but with side-aware gating. Ensure each faction keeps separate HC group lists, reinforcement options, and call-ins.
* Provide spectator/respawn handling that respawns players at their faction HQ markers and uses side-restricted arsenal templates.

### 4. Economy & Logistics Split

* Duplicate the FIA resource variables into hash map-backed entries (`resources`, `hr`, `storage`, etc.).
* Update economy scripts (e.g. `fn_resourcesFIA.sqf`, `fn_buildMinefield.sqf`, reinforcement purchasing scripts) to accept a `side` parameter. Default to `teamPlayer` to preserve backwards compatibility. In Civil War mode pass either `Occupants` (NATO) or `Invaders` (CSAT).
* Adjust save/load routines to serialise the new hash map structure with versioning to avoid corrupting legacy saves.

### 5. HQ & Territory Mechanics

* Reuse rebel HQ relocation logic for each faction by parameterising `fn_moveHQ`, `fn_buildHQ`, and related helpers.
* Markers: maintain `"NATO_carrier"` and `"CSAT_carrier"` as initial HQ markers, but allow movement similar to the rebel camp system.
* Garrisons: allow both commanders to create garrisons in controlled territory by duplicating the FIA outpost creation flow but binding to the faction’s side ID.

### 6. AI Automation for FIA & AAF

* Instantiate existing AI attack/defence loops for FIA (rebels) and AAF (government) by keeping their current `teamPlayer`/`Occupants` designations when Civil War mode is active.
* Provide a new scheduler that ensures AI factions continue to attack and defend markers, but never spawn player-specific logistics.

### 7. UI & Feedback

* Update UI dialogues (HQ management, reinforcement purchase, mission requests) to be side-aware. For Civil War mode show or hide options based on the player’s side.
* Add map indicators for both HQs and separate resource displays in the commander HUD.

### 8. Testing Strategy

* Regression test existing game modes to ensure single-commander flow still works.
* Create dedicated Civil War scenarios focusing on:
  * Commander handoff
  * HQ relocation
  * Resource spending and reinforcements for both sides
  * Save/load round-trip of the new structures
  * AI behaviour of FIA/AAF while players control NATO/CSAT

## Implementation Phases

1. **Data layer refactor** – Introduce side-aware commander/economy maps and migrate scripts gradually while maintaining compatibility.
2. **Game mode plumbing** – Add the Civil War parameter, initialisers, and HQ spawning logic.
3. **Commander UX** – Implement claim actions, HC group management, and reinforcement purchases for each side.
4. **Economy integration** – Update purchasing/building scripts to accept a side parameter and consume the correct pools.
5. **AI adjustments** – Lock FIA/AAF to AI automation and ensure their activities do not require player commanders.
6. **UI polish & testing** – Update dialogues and overlays, then run through smoke tests and publish documentation for server hosts.

## Open Questions

* Save compatibility: should Civil War mode be a separate save namespace to avoid mixing with standard campaigns?
* Slot management: will each faction have dedicated playable units, or can any player join either side mid-mission?
* Balance tweaks: aggression multipliers, resource ticks, and reinforcement availability may need tuning for PvP pacing.

---

This refactor touches almost every subsystem. By introducing side-agnostic helpers and a clean commander registry, we can incrementally migrate the existing FIA-centric logic without rewriting the entire mission framework.
