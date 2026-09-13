# Neon Clash — Asset Manifest

## Art direction

The game uses a **premium, restrained Web3 arena** style: midnight-blue glass panels, cyan and violet edge light, a subtle star-field, and a thin horizon-grid. The gameplay field is uncluttered so that two collectible alien portraits and the Rock–Paper–Scissors choice states remain the focal points. Typography is high contrast and compact; the UI should read clearly on both a desktop browser and a mobile screen.

## Reference

| Asset | Purpose | Notes |
| --- | --- | --- |
| `art/reference_nft_rps_pvp.png` | Finished-game visual target | Generated as a 16:9 Redot-compatible UI reference. It informs the arena, HUD, card, and action-button hierarchy. |

## Prototype avatar assets

| Asset | Mock NFT identity | Facing direction | Use |
| --- | --- | --- | --- |
| `assets/avatars/verdant_orbit.png` | Verdant Orbit #001 | Right | Default local player portrait. |
| `assets/avatars/nebula_rift.png` | Nebula Rift #002 | Left | Default simulated opponent portrait. |
| `assets/avatars/solar_echo.png` | Solar Echo #003 | Right | Alternate mock selection. |
| `assets/avatars/tide_vector.png` | Tide Vector #004 | Left | Alternate mock selection. |

All four avatar assets are original mock artwork created for the prototype. They are **not** retrieved OpenSea collection media. The `MockNFTProvider` preserves a collection-shaped metadata structure and can be populated with permitted collection item media/metadata later.

## UI implementation assets

Panels, buttons, progress states, the portal, countdown treatment, and RPS symbols are constructed with Redot controls and theme overrides rather than baked textures. This keeps the browser build small and lets the layout adapt to narrow displays.
