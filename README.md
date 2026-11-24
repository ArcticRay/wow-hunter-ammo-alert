# HunterAmmoAlert

A lightweight addon for **World of Warcraft Forever** that helps hunters keep track of their ammunition.

Never run out of arrows or bullets unexpectedly again!

## Features

- **Low Ammo Warning:** Displays an on-screen warning when your ammunition drops below 200.
- **Configurable Threshold:** Set your own ammunition limit.
- **Sound Alert:** Plays a warning sound when ammunition runs low.
- **Draggable Warning Frame:** Move the warning using `SHIFT + Left Mouse Button`.
- **Saved Position:** Your warning position is saved between sessions.
- **Smart Notifications:** Avoids repeatedly playing the warning sound while ammunition remains below the threshold.

## Installation

1. Download or clone this repository.
2. Extract the `HunterAmmoAlert` folder.
3. Place it inside your WoW Forever AddOns directory:

   ```text
   World of Warcraft/
   └── Interface/
       └── AddOns/
           └── HunterAmmoAlert/
               ├── HunterAmmoAlert.toc
               └── HunterAmmoAlert.lua
   ```

4. Restart the game or type `/reload`.
5. Make sure HunterAmmoAlert is enabled in the AddOns list.

## Commands

| Command              | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| `/haa status`        | Displays your current ammunition count and warning threshold. |
| `/haa threshold 200` | Sets the warning threshold to 200.                            |
| `/haa threshold 100` | Example: Changes the threshold to 100.                        |

## Moving the Warning

Hold **SHIFT + Left Mouse Button** on the warning frame and drag it to your preferred position.

The position is automatically saved.

## Configuration

The default warning threshold is **200 ammunition**.

You can change it at any time using:

```text
/haa threshold <number>
```

## Compatibility

- Game: WoW Forever
- Character class: Hunter
- Interface: 16001

## License

MIT License (see [LICENSE](LICENSE) if included).

---

Made for hunters who don't want to run out of arrows mid-fight. 🏹
