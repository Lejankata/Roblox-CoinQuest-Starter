# Manual Test Checklist

Use a fresh Baseplate experience before testing. Open **View > Output** in Roblox Studio to see warnings and errors.

## Basic gameplay

- [ ] Spawn into the game without errors in Output.
- [ ] See 12 glowing yellow spheres around the spawn.
- [ ] Walk toward a coin and see the **Collect +10** prompt.
- [ ] Press E on desktop; balance rises by 10.
- [ ] Collecting the same coin repeatedly before respawn does not award extra currency.
- [ ] Collected coins become visible again after 12 seconds.
- [ ] Leaderboard and HUD display the same amount.
- [ ] Reset the character; balance stays the same in the current session.

## Mobile

- [ ] In Studio's device emulator, switch to a phone layout.
- [ ] HUD remains visible without covering essential default controls.
- [ ] Interaction prompt appears on mobile.
- [ ] No text clipping or overlap occurs.

## Persistence

- [ ] Publish a private test experience.
- [ ] Enable Studio API Services for that test experience.
- [ ] Collect several coins.
- [ ] Stop and restart the game; balance returns.
- [ ] Check Output after forcing a DataStore failure in a safe test environment.
- [ ] Never use production DataStore data while testing destructive changes.

## Multiplayer

- [ ] Start a two-player local server test.
- [ ] Each player has an independent balance.
- [ ] One coin is globally unavailable after either player collects it.
- [ ] Clients do not directly decide currency awards.

## Future improvements

- Session locking and stronger cross-server persistence
- A reusable ModuleScript instead of a single installation script
- Automated tests via TestEZ or a similar runner
- Per-player collectibles and customizable coin placement
- Accessibility settings for UI contrast and motion
