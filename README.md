# Button of Zero

**Button of Zero** is a fast-paced, high-tension puzzle and puzzle-defusal game inspired by classic frantic button-mashing games. You have seconds on the clock to decipher, adjust, and solve various modules—from sliders and number boxes to complex equations and sequences—before time runs out!

Built entirely in **Zig** and powered by **Raylib**.

---

## Features

- **Frantic Gameplay:** Race against a countdown timer with dynamic music that intensifies based on difficulty.
- **Diverse Modules:** Defuse multiple types of randomised puzzles:
  - Sliders & Knobs
  - Number Boxes & Counters
  - Dropdowns & Equations
  - Toggles, Sequences, and Logic gates
- **Multiple Difficulties:** Easy, Medium, and Hard tiers offering varying module counts and time limits.

---

## Prerequisites

To build and run this project from source, you need:
- **Zig Compiler** (v0.16.0 or newer)
- **Git** (for fetching Raylib dependencies via Zig package manager)

---

## Building and Running

1. **Clone the repository:**
  ```bash
  git clone https://github.com/your-username/button-of-zero.git
  cd button-of-zero
  ```

2. **Run the game directly:**
  ```bash
  zig build run
  ```

3. **Build an optimised release binary:**
  ```bash
  zig build -Doptimize=ReleaseSafe
  ```
  The compiled executable will be located in `zig-out/bin/`.

---

## Project Structure

- `src/main.zig` - Window management, rendering, and game loop GUI.
- `src/game.zig` - Core game loop state, timer management, and module generation.
- `src/module.zig` - Unified module definitions and interactive puzzle components.
- `src/difficulty.zig` - Difficulty tiers and rule sets.
- `src/timer.zig` - Countdown timer logic.
- `src/audio.zig` - Raylib music stream integration.

---

## Credits

### Music
  - Basics by Ravi's World, own work
  - <ruby>中間性<rt>ちゅうかんせい</rt></ruby> by Ravi's World, own work
  - Symbiosis (Remix) by Cedric Vermue on Uppbeat
    - https://uppbeat.io/c/cedric-vermue
  - Tada by Ravi's World, own work

### SFX
  - Meme boom - deep fried by Jam FX on Uppbeat

### Images
  - Favicon created by [riajulislam on Flaticon](https://www.flaticon.com/free-icons/numbers)


---

## License

Distributed under the GNU Affero General Public License. See `LICENSE` for more information.