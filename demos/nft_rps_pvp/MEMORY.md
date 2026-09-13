# Neon Clash — Build Memory

The connected repository is the Redot Engine source tree rather than an existing game project. The prototype therefore lives in the isolated directory `demos/nft_rps_pvp` and does not modify engine source files.

## Verified runtime facts

| Check | Outcome |
| --- | --- |
| Redot project import and GDScript parsing | Passed with Redot LTS 26.2. |
| Core smoke test | Passed: RPS win/draw rules, commit/reveal mismatch rejection, same-stake prize pool, and virtual settlement. |
| Headless main-scene startup | Passed without UI initialization errors. |
| Web export | Passed; generated HTML, JavaScript, WebAssembly, PCK, and image files in `build/`. |
| Browser startup | Passed in Chromium using WebGL 2 compatibility rendering. The lobby rendered its stake controls, NFT character cards, virtual balance, and queue action without console errors. |

## Visual check observations

The browser lobby rendered in the intended dark-glass, cyan/violet style. The user owns two local mock NFT records, so the selection grid intentionally shows two selectable cards; the metadata file contains four total records for player/opponent simulation. The top of the page includes normal browser canvas space; the game UI is visible and functional underneath it.

## Scope guardrails

This prototype includes no blockchain integration, wallet connection, cryptocurrency transfer, smart contract, external NFT ownership verification, or real-money betting. The OpenSea collection page did not expose stable item media in the sandbox browser, so default portraits are original mock assets. `MockNFTProvider` can be replaced later with an authorized collection metadata provider.

## Browser input-test note

The exported lobby rendered correctly in Chromium. The browser automation’s generic canvas click did not transition the in-canvas Redot button, including a synthetic pointer-event attempt. This is a tooling interaction limitation rather than a detected game runtime error; the headless project startup and game-logic smoke test passed. The source exposes normal Redot `Button` controls for a human browser user.
