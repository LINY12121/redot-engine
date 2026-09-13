# Neon Clash: Mock NFT Rock–Paper–Scissors PvP

**Neon Clash** is a browser-first Redot Engine prototype in which two collectible-character players contest a Best-of-5 Rock–Paper–Scissors match. It has a polished dark-glass arena, original mock alien avatar art, fixed virtual-stake queues, a local commit–reveal flow, and mock prize settlement. It deliberately contains **no wallet connection, blockchain, smart contract, cryptocurrency, NFT ownership verification, or real-money wagering**.

The prototype is located at `demos/nft_rps_pvp` so it remains isolated from the Redot Engine source tree. It is intended to be a practical starting point for a future production game, not a financial or betting product.

> **Scope boundary:** Every displayed balance, stake, prize pool, player, and NFT ownership record is local mock data. A player cannot deposit, withdraw, transfer, or risk real assets in this build.

## Game experience

The player selects a local mock NFT character and one virtual stake. The mock matchmaker simulates a same-stake opponent, locks two virtual stakes, and starts the arena. A non-draw Rock–Paper–Scissors result awards one round point; the first side to reach three wins takes the virtual prize pool. Draws reveal both moves but leave both scores unchanged.

| Element | Prototype behavior |
| --- | --- |
| Match format | Best-of-5, first to 3 non-draw round wins. |
| Moves | Rock defeats Scissors; Scissors defeats Paper; Paper defeats Rock. |
| Stakes | Fixed virtual credits: `$1`, `$2`, `$5`, and `$10`. |
| Matchmaking | The mock queue pairs only the exact same stake amount. |
| Prize pool | Two locked virtual stakes; for example, `$5` vs `$5` produces a `$10` virtual pool. |
| Character selection | Two locally owned mock NFTs are selectable; four sample records exist for both player/opponent simulation. |
| Settlement | The mock winner’s local credit balance receives the virtual pool. |
| Browser layout | A responsive `Control` scene designed for desktop and narrow browser displays. |

## Run locally

Install a matching **Redot LTS 26.2** editor and its export templates, then open the project folder in Redot. Press **Run Project** from the editor, or use the following commands from the repository root.

```bash
cd demos/nft_rps_pvp
/path/to/redot --path .
```

The project’s main scene is `scenes/main.tscn`. The main UI launches at the lobby, where you choose a virtual stake and avatar. Select **Find Opponent**, wait for the local mock pairing, choose **Ready**, and use the Rock, Paper, or Scissors controls in the arena.

### Automated checks

The core rules have a smoke-test script covering RPS outcomes, draw behavior, commitment validation, same-stake virtual prize calculation, and settlement. Run it with:

```bash
cd demos/nft_rps_pvp
/path/to/redot --headless --path . --script res://tests/smoke_test.gd
```

A deterministic game-flow autopilot is also available for local verification. It takes the mock player from queueing through a three-round victory:

```bash
cd demos/nft_rps_pvp
/path/to/redot --headless --path . -- --demo
```

## Export for Web

The repository includes `export_presets.cfg` with a single-threaded Web preset for broad browser compatibility. In the Redot editor, choose **Project → Export**, select **Web**, and export to `build/neon_clash.html`. The exported HTML, JavaScript, WebAssembly, PCK, and images must be served over HTTP(S); opening the HTML file directly from the filesystem is not appropriate for a WebAssembly game.

For command-line export, use:

```bash
cd demos/nft_rps_pvp
/path/to/redot --headless --path . --export-release Web build/neon_clash.html
```

The generated `build/` directory is intentionally ignored by Git because it is a reproducible compiled artifact.

## Architecture

The game logic is consciously independent from any particular blockchain. UI and match code do not import a wallet SDK or make network-specific decisions. Future implementations are inserted through provider interfaces.

| Layer | Key files | Responsibility |
| --- | --- | --- |
| Application and UI | `scripts/app.gd`, `scripts/ui/ui_manager.gd` | Lobby, selection, matchmaking state, arena HUD, results, adaptive visual styling, and UI transitions. |
| Gameplay | `scripts/gameplay/game_manager.gd`, `match_manager.gd`, `round_manager.gd`, `player_manager.gd` | State flow, Best-of-5 scoring, verified round resolution, and match settlement orchestration. |
| Fairness | `scripts/services/commit_reveal_service.gd` | Generates a random secret, computes a SHA-256 commitment, records both commitments, verifies both reveals, then exposes verified moves only. |
| Mock services | `scripts/services/mock_*` | Local NFT records, virtual balance, stake locking, same-stake matching, and virtual prize settlement. |
| Replaceable interfaces | `nft_provider.gd`, `wallet_service.gd`, `bet_provider.gd`, `settlement_provider.gd`, `matchmaking_service.gd` | Stable seams for future production implementations. |
| Content | `data/mock_nfts.json`, `assets/avatars/` | Mock collection-shaped metadata and original local character art. |

The documents `PLAN.md`, `STRUCTURE.md`, `ASSETS.md`, and `MEMORY.md` record build decisions, visual direction, asset sources, and verification results.

## Commit–reveal fairness flow

The prototype uses the following local protocol for each round. The opponent is simulated in this stage, but the method preserves the ordering that a real client/server implementation needs.

| Phase | Action | What is visible to the other side |
| --- | --- | --- |
| Commit | Each player creates a random secret and computes `SHA256(choice + ":" + secret)`. | Only the hash commitment. |
| Lock | The service waits until both player IDs have submitted one commitment. | Neither raw move is exposed. |
| Reveal | Each player supplies its choice and secret. The service recomputes the hash and rejects a mismatch. | Both moves appear only after the locked commitments validate. |
| Resolve | `RoundManager` compares the two verified moves and updates only a non-draw score. | The round result and updated score. |

This is a **local demonstration**, not sufficient to secure a real-money deployment. A production version needs an authoritative multiplayer backend, timeouts and forfeiture rules, authentication, replay protection, auditable match records, and an independently reviewed settlement design.

## Mock NFT data and OpenSea collection note

The data records use a future-ready NFT metadata shape: `token_id`, `collection_address`, `name`, `image`, `attributes`, and `owner`. The default images are original mock alien art. They are not downloaded or claimed to be images from the user-provided OpenSea collection.

The user-provided OpenSea collection page, [`ALIENS 0.0005 ETH`](https://opensea.io/collection/aliens-on-rh), is recorded as a future metadata source. To integrate real collection items later, replace `MockNFTProvider` with a provider that fetches authorized metadata and verifies ownership, then supply permitted image URLs or locally licensed copies. Do not assume that viewing or owning an NFT automatically grants commercial game-art usage rights; license terms and creator permissions must be established before public use.

## Future integration points

When a blockchain and production multiplayer stack are selected, replace concrete mock services without changing the UI or RPS core.

| Current implementation | Future implementation responsibility |
| --- | --- |
| `MockWalletService` | Wallet connection and account/session state. |
| `MockNFTProvider` | Ownership verification and authorized metadata retrieval. |
| `MockBetProvider` | Chain-appropriate stake approval and escrow logic. |
| `MockSettlementProvider` | Verified settlement after authoritative match completion. |
| `MockMatchmakingService` | Real-time same-stake queueing through an authoritative backend. |
| Local `CommitRevealService` transport | Signed commitment/reveal messages, deadlines, forfeit handling, and server-side validation. |

No future adapter should hard-code Ethereum, Base, Robinhood Chain, Solana, or any other network into the game layer. Select the chain later at the provider implementation boundary.

## Repository hygiene

Generated Redot cache files and compiled Web output are ignored. Source code, scene configuration, mock data, tests, documentation, and original lightweight avatar assets are tracked so another developer can reproduce the prototype.
