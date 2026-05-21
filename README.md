# 🐦 Flappy Bird — x86 Assembly (.COM)

A fully-featured Flappy Bird clone written from scratch in **8086 Assembly Language**, compiled to a single `.COM` binary and running directly in DOS or a DOS emulator. No C runtime, no libraries — just raw interrupt calls, PC speaker beeps, and 80×25 text-mode graphics.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Single-player mode** | SPACE to flap, gravity pulls you down, 3 lives |
| **2-player co-op/VS** | P1 = SPACE · P2 = ENTER, shared pipes, first to die loses |
| **Dynamic difficulty** | Pipe speed increases every 5 points (up to 4× base speed) |
| **Star power-up** | Collectible `≈` token grants an extra flap boost |
| **Animated bird** | 3-frame wing animation (`\o/` · `-o-` · `/o\`) |
| **Scrolling ground** | Animated ground strip on row 23 |
| **City skyline** | Static per-column building backdrop drawn with block characters |
| **HUD** | Live score (3-digit), lives, speed level, boost indicator |
| **File leaderboard** | Top-3 scores + names persisted to `SCORES.DAT` across sessions |
| **PC Speaker audio** | Non-blocking jump chirp + blocking death slide |
| **XOR PRNG** | Timer-seeded pseudo-random pipe gaps |
| **Name entry** | Up to 20-character username with backspace support |
| **Help screen** | In-game controls reference |
| **Graceful exit** | Restores cursor and prints a farewell message |

---

## 🎮 Controls

### Single Player
| Key | Action |
|---|---|
| `SPACE` | Flap upward (×3 if boost active) |
| `ESC` | Quit to menu (saves score) |
| `↑` / `↓` | Navigate main menu |
| `ENTER` | Select menu item |

### 2-Player
| Key | Player |
|---|---|
| `SPACE` | Player 1 (Yellow bird) flap |
| `ENTER` | Player 2 (Red bird) flap |
| `ESC` | Quit match |

---

## 🏗️ Architecture

The entire game is a single **NASM flat-binary `.COM` file** (`org 100h`). All code and data share the same 64 KB segment — no linker, no segments to manage.

### Key subsystems

```
start
 ├── load_scores          ; Read SCORES.DAT into lb_scores buffer
 ├── name_input           ; Keyboard-buffered name entry
 └── main_menu            ; Arrow-key menu loop
      ├── game            ; Single-player loop
      │    ├── init_game
      │    ├── .game_loop
      │    │    ├── erase / draw bird, pipes, star
      │    │    ├── gravity + jump input
      │    │    ├── pipe tick gate → move_pipes / randomize_pipe
      │    │    ├── update_star  (spawn, move, collect)
      │    │    ├── check_collision → lose_life / game_over
      │    │    ├── update_score → update_speed
      │    │    └── PC speaker tick (non-blocking)
      │    └── game_over_screen → save_score → save_scores
      ├── game_2p          ; Mirrored loop for two birds
      ├── show_leaderboard ; Reads lb_scores, prints top-3
      └── help_screen
```

### Important routines

| Routine | Purpose |
|---|---|
| `xor_rand` | XOR-shift PRNG seeded from BIOS timer tick (`INT 1Ah`) |
| `randomize_pipe` | Uses PRNG to set `gap_top[bx]` in range 4–13 |
| `restore_bg_char` | Repaints sky / building roof / building body under any erased sprite |
| `update_speed` | `pipe_move_rate = max(1, 4 - score/5)` |
| `save_score` | Inserts current score into sorted 3-slot leaderboard, shifts others down |
| `delay_loop` | Busy-wait using `delay_count` byte for frame pacing |
| `speaker_on/off` | Direct Port 42h/43h/61h PC speaker control |
| `sound_jump` | Non-blocking: enables speaker for 2 frames via `jump_sound_timer` |
| `sound_death` | Blocking descending three-tone slide |

---

## 📁 File Structure

```
Flappy-Bird-Assembly-x86/
├── main.asm        # Entry point, game loops, HUD, bird logic
├── menu.inc        # Menu, name input, leaderboard, help screen  (if split)
├── flappy.asm      # Monolithic build (single-file version)
└── SCORES.DAT      # Auto-created on first run — top-3 leaderboard (66 bytes)
```

> **`SCORES.DAT` format:** 3 slots × 22 bytes = 66 bytes total.  
> Each slot: `[1 byte score][21 bytes name (null/$-padded)]`

---

## 🛠️ Build & Run

### Requirements
- [NASM](https://www.nasm.us/) assembler
- A DOS environment: [DOSBox](https://www.dosbox.com/), [DOSBox-X](https://dosbox-x.com/), [emu8086](http://emu8086.com/), or real DOS

### Assemble
```bash
nasm flappy.asm -f bin -o flappy.com
```

### Run in DOSBox
```
dosbox flappy.com
```
Or mount the folder and run from the DOSBox prompt:
```
mount c path\to\project
c:
flappy
```

### Notes
- `SCORES.DAT` is created automatically in the same directory on first play.
- The binary is a pure 16-bit real-mode `.COM` file — it will not run natively on 64-bit Windows/Linux without a DOS emulator.

---

## 🖥️ Display

The game uses **BIOS INT 10h** calls exclusively — no direct video memory writes. It runs in the default 80×25 text mode (mode 03h) and uses BIOS colour attributes for all rendering (pipes in green, bird in yellow/red, ground in brown/white, sky in cyan).

### Playfield layout
```
Row  0    ┌─ HUD: Score │ Speed │ Lives │ Boost ─┐
Row  1-22 │         Playfield (pipes + bird)       │
Row 23    └─────── Scrolling ground strip ─────────┘
```

---

## 🧠 Technical Highlights

- **No external dependencies** — 100% BIOS/DOS interrupts (`INT 10h`, `INT 16h`, `INT 21h`, `INT 1Ah`)
- **Non-blocking audio** — jump sound runs concurrently with game physics via a frame timer instead of a blocking delay
- **Register discipline** — `BX` used as pipe index in drawing routines; all callers `push`/`pop` BX around `print_char` calls to prevent clobbering
- **Background restoration** — `restore_bg_char` correctly repaints the multi-layer background (sky → building body → rooftop) after any sprite is erased, avoiding visual artifacts
- **Gravity tick** — gravity applies every 2 frames (`gravity_tick`) to allow jump input to consistently outpace fall speed
- **Score overflow safe** — `update_speed` uses 16-bit `MUL`/`DIV` with explicit `DX` clearing to avoid divide overflow on higher scores

---

## 📜 License

This project is released for educational purposes. Feel free to study, fork, and modify.

---

## 👤 Author

**Bilal Aamir** — [github.com/BilalAamir4](https://github.com/BilalAamir4)
