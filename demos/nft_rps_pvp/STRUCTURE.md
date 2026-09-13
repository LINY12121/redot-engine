# Neon Clash — Architecture

## Design principle

The prototype is **chain-independent**. Gameplay objects never call a wallet, blockchain, NFT indexer, smart contract, or payment provider directly. Instead, they depend on small service interfaces that can later receive production implementations.

```text
UI (NeonClashApp)
        │
        ├── MatchManager ── RoundManager
        │         │                │
        │         ├── CommitRevealService
        │         ├── MatchmakingService
        │         └── BetService / SettlementProvider
        │
        ├── NFTProvider
        └── WalletService

Current concrete implementations: MockNFTProvider, MockWalletService,
MockBetProvider, MockSettlementProvider, MockMatchmakingService.
```

## Folders

| Path | Purpose |
| --- | --- |
| `scripts/app.gd` | Main `Control` scene controller and UI state transitions. |
| `scripts/services/` | Replaceable mock providers and the commit/reveal service. |
| `scripts/gameplay/` | Chain-agnostic round and match orchestration. |
| `scripts/ui/` | Theme and reusable UI construction helpers. |
| `data/mock_nfts.json` | Mock NFT records shaped like future indexed NFT metadata. |
| `assets/avatars/` | Original mock avatar art used only by the prototype. |
| `art/reference_nft_rps_pvp.png` | Visual-target reference for the UI direction. |

## Service boundaries

| Service | Current mock responsibility | Future replacement responsibility |
| --- | --- | --- |
| `NFTProvider` | Returns local metadata records and asset paths. | Verifies ownership and retrieves indexed metadata for the chain chosen later. |
| `WalletService` | Holds a local virtual-credit balance. | Connects a selected wallet provider without exposing chain details to game logic. |
| `BetProvider` | Validates and locks virtual stakes. | Creates a chain-specific escrow or approved allowance flow. |
| `SettlementProvider` | Credits the mock winner. | Settles a verified result on the selected network. |
| `MatchmakingService` | Simulates same-stake pairing with a local opponent. | Sends queue messages to a real authoritative multiplayer backend. |
| `CommitRevealService` | Generates SHA-256 commitments and validates reveals locally. | Exchanges commitments/reveals through the authoritative backend or protocol. |

## Fairness model

For each round, each player produces a random secret. Their commitment is the SHA-256 hash of `choice + ":" + secret`. Both commitments must arrive before either choice is revealed. The service recomputes each hash during reveal, then hands verified choices to `RoundManager`. In this single-client prototype, the opponent is simulated; the API deliberately mirrors a future two-client / server flow.

## Browser note

The project uses a single `Control`-based scene with scale mode set to `canvas_items`. It is suitable for the Redot web export pipeline after the engine’s Web export templates are installed. No browser wallet SDK is bundled in this phase.
