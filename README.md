# CoinQuest Starter for Roblox Studio

A small, original, open-source Roblox Studio starter project. Drop in two Luau scripts to give a Baseplate game collectible coins, a server-validated coin balance, optional persistent player data, and a mobile-friendly HUD.

**Built for learning.** No paid plugins, external assets, or third-party dependencies are needed.

## Features

- 12 glowing, collectible coins created automatically around a SpawnLocation
- E key / mobile-friendly ProximityPrompt collection
- Server-side validation before awarding coins
- Visible leaderboard and a custom coin counter UI
- Coins disappear after collection and return after 12 seconds
- DataStore saving, periodic autosave, and save-on-exit
- Full, editable Luau source code

## Install in Roblox Studio

1. Open Roblox Studio and create a new Baseplate experience.
2. In **View**, enable **Explorer** and **Properties**.
3. Under **ServerScriptService**, add a new **Script**. Rename it `CoinServer`.
4. Replace that Script's contents with the complete code from [`scripts/CoinServer.server.luau`](scripts/CoinServer.server.luau).
5. Under **StarterPlayer > StarterPlayerScripts**, add a **LocalScript**. Rename it `CoinHUD`.
6. Replace the LocalScript's contents with the code from [`scripts/CoinHUD.client.luau`](scripts/CoinHUD.client.luau).
7. Click **Play**. Walk near a glowing coin and press **E** (or the on-screen collect prompt on a touchscreen).
8. Watch your balance increase on the HUD and leaderboard.

### Enable saving

Coin collecting works in Studio even when DataStore access is unavailable, but persistent saving needs proper setup:

1. Publish your experience to Roblox.
2. Open **Game Settings > Security** (the exact menu location can vary by Studio version).
3. Enable **Studio Access to API Services** only for your **test** experience when testing saving in Studio.
4. Rejoin and verify the balance is restored.

**Keep production player data separate from Studio testing.** API access allows Studio to read and write live DataStore data for the experience.

## Customize

Open `CoinServer` and adjust the `CONFIG` table near the top:

| Setting | Default | Meaning |
|---|---:|---|
| `CoinCount` | 12 | Number of coins around the spawn |
| `CoinValue` | 10 | Coins awarded per pickup |
| `RespawnSeconds` | 12 | Seconds before a pickup becomes available again |
| `RingRadius` | 34 | Distance from SpawnLocation |
| `CollectDistance` | 14 | Maximum allowed pickup distance (server check) |
| `SaveIntervalSeconds` | 60 | How often dirty balances are saved |
| `DataStoreName` | `CoinQuestStarter_v1` | Storage namespace; change before using in a separate game |

## Project structure

```text
Roblox-CoinQuest-Starter/
├── scripts/
│   ├── CoinServer.server.luau
│   └── CoinHUD.client.luau
├── docs/
│   └── TESTING.md
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Security and limitations

- Rewards are awarded **only on the server**. The HUD never controls currency.
- The server checks the player's distance and prevents multiple rewards while a coin is unavailable.
- This is a small **learning starter**, not a production economy framework. For live games with trading, purchases, or high concurrency, consider a mature session-locking data library, server-side transaction logs, and abuse monitoring.
- Coins are shared across the server. When one player collects a coin, everyone waits for its respawn.
- If a player's stored balance fails to load, collecting works for that session but the balance is **not saved**, preventing an overwrite of existing data. Rejoin when the service is available.

## Test it

See [`docs/TESTING.md`](docs/TESTING.md) for a manual checklist. This project has **not** been playtested in a live Roblox Studio session by its initial author. Please verify all behavior before publishing a public experience.

## Contributing

Bug reports, documentation improvements, and pull requests are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

MIT. See [`LICENSE`](LICENSE).

---

**Note:** Publishing this repository does not automatically qualify anyone for Anthropic's Claude for Open Source promotion. Program decisions depend on genuine open-source impact and eligibility.
