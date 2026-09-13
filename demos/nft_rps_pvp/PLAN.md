# Neon Clash — Implementation Plan

## Product scope

**Neon Clash** is a browser-first, two-player Rock–Paper–Scissors PvP prototype for Redot Engine. This stage is deliberately free of blockchain, smart contracts, wallet connections, cryptocurrency, and real-money settlement. Each player uses a mock NFT character and virtual credits only.

## Playable flow

| Step | Player experience | Prototype behavior |
| --- | --- | --- |
| 1 | Select NFT character | The local player selects one of four mock NFT records. |
| 2 | Select a stake | The player chooses 1, 2, 5, or 10 virtual credits. |
| 3 | Find opponent | A mock matchmaking queue pairs the player only with the same selected stake. |
| 4 | Match found | Both virtual stakes are locked; the arena transitions in. |
| 5 | Best-of-5 RPS | The first player to reach three non-draw wins takes the match. |
| 6 | Commit/reveal | Each choice is committed with a secret hash before both choices reveal. |
| 7 | Settlement | The mock winner receives the virtual prize pool. |
| 8 | Result | The player can rematch or return to the lobby. |

## Risk slices

| Risk | Mitigation | Verification criterion |
| --- | --- | --- |
| Opponent choice leaks before lock | Keep choices only in `CommitRevealService` until both commitments exist. | The UI shows only `Choice locked` before reveal, never the opponent’s move. |
| Mismatched stakes pair incorrectly | Queue dictionaries are keyed by exact integer stake. | A selected $5 stake creates a $5 vs $5 match and a $10 prize pool. |
| Draws incorrectly count | `RoundManager` updates scores only for a non-draw result. | A draw repeats the round number and does not change either score. |
| Future chain coupling | UI and game logic depend on provider interfaces, not mock implementations. | `Mock*` providers are instantiated in one location and expose replaceable APIs. |
| Browser layout becomes cramped | Use anchor presets and compact responsive containers. | The UI remains usable at desktop and portrait-mobile aspect ratios. |

## Implementation sequence

1. Establish a standalone Redot project under `demos/nft_rps_pvp` without modifying the engine source.
2. Implement mock NFT, wallet, betting, settlement, matchmaking, and commit/reveal services.
3. Build round and match managers for Best-of-5 scoring and virtual prize payout.
4. Create a polished adaptive UI with lobby, match-found, arena, and result states.
5. Configure browser export guidance and validate scripts through the Redot runtime when available.
6. Document the architecture, mock behavior, and future integration seams.

## Acceptance criteria

The deliverable is complete when a user can select an avatar and stake, enter a same-stake mock queue, play a full Best-of-5 RPS match, observe commit/reveal status, receive a virtual prize on a win, and replay or exit. It must include several mock NFT metadata records, use no real chain or real-money functionality, and keep all future blockchain dependencies behind interfaces.
