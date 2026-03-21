<div align="center">

# 🕹️ OL Pac-Man Remade

A fully custom **Pac-Man remake** built from scratch in **Godot 4**  
with self-implemented ghost AI, live online leaderboard & persistent player accounts.

<br/>

![Godot](https://img.shields.io/badge/Godot-4.6.1-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-100%25-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![OpenGL](https://img.shields.io/badge/Renderer-OpenGL_3.3-5586A4?style=for-the-badge&logo=opengl&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows_%7C_Web-0078D6?style=for-the-badge&logo=windows&logoColor=white)

</div>

---

## 📖 Table of Contents

- [What is Pac-Man?](#-what-is-pac-man)
- [How to Play](#-how-to-play)
- [Technical Details](#-technical-details)
- [Ghost AI & Pathfinding](#-ghost-ai--pathfinding)
- [Architecture](#-architecture)
- [Online Leaderboard System](#-online-leaderboard-system)
- [Tech Stack](#-tech-stack)

---

## 🎮 What is Pac-Man?

Pac-Man is a classic **1980 arcade game** originally developed by **Namco**. It became one of the most iconic video games ever made and defined an entire era of gaming.

The concept is simple: you control **Pac-Man**, a yellow circle navigating a maze, eating dots while being chased by four coloured ghosts. Eat all the dots to complete the level — but get caught by a ghost and you lose a life.

**Power Pellets** scattered in the corners of the maze temporarily turn the ghosts blue and vulnerable — giving you the chance to eat them for bonus points. After a short time they return to normal, so act fast.

The game was revolutionary for its time because of its **ghost AI** — each ghost has a distinct personality and behaviour, making the game feel alive and unpredictable. This remake stays true to those original mechanics.

---

## 🕹️ How to Play

| Input | Action |
|---|---|
| `Arrow Keys` / `WASD` | Move Pac-Man |
| Eat all dots | Clear the level |
| Eat a **Power Pellet** | Ghosts turn blue and are vulnerable |
| Eat a **blue ghost** | Bonus points (200 → 400 → 800 → 1600 per ghost in a chain) |
| Avoid normal ghosts | Getting touched = lose a life |

**Tips:**
- Use the tunnels on the sides of the maze — ghosts slow down inside them
- Plan your route to eat ghosts in chains after a Power Pellet for maximum score
- Keep an eye on the ghost colours — they flash white just before they recover

---

## 📊 Technical Details

### Scoring

| Event | Points |
|---|---|
| Small Dot | 10 |
| Power Pellet | 50 |
| Ghost (1st after pellet) | 200 |
| Ghost (2nd in chain) | 400 |
| Ghost (3rd in chain) | 800 |
| Ghost (4th in chain) | 1,600 |

### Milestones

| Score | Event |
|---|---|
| **10,000** | 🎁 Extra life awarded (once per session) |

### Level Completion

- Each level contains **244 collectible dots** (small dots + power pellets)
- Collecting all 244 triggers `levelcompletecheck()` and advances to the next level
- Level counter increments with each completed stage

### Level Scaling

- Difficulty increases with each level
- Internal level is **capped at 19** for game balance calculations — beyond that difficulty stays consistent to avoid the game becoming unplayable
- The actual level counter keeps incrementing and is shown on the leaderboard

### Lives

- Start with **4 lives**
- Lose a life when touched by a non-frightened ghost
- Extra life at **10,000 points** (once per session)
- Game Over when all lives are gone

### Movement System

- Pac-Man moves via a **timer-based pixel-step system** (fires every 25ms)
- Four directional **collision area sensors** (up, right, down, left) detect walls in real time
- Input is **buffered** — the last pressed direction is stored and applied as soon as the path clears, enabling smooth corner turns

---

## 🧠 Ghost AI & Pathfinding

All ghost AI is **implemented from scratch** — no NavMesh, no built-in Godot pathfinding. Each ghost uses a custom **tile-based grid traversal** system with BFS-style route calculation.

### The Three Phases

Ghosts cycle through three behaviour phases during a game. Phase timing changes as levels increase.

#### 🔵 Scatter Phase
Each ghost retreats to a **fixed home corner** of the maze and loops there indefinitely. This gives the player a brief moment of relief and prevents the ghosts from always converging on Pac-Man.

| Ghost | Scatter Target |
|---|---|
| 🔴 Blinky | Top-right corner |
| 🩷 Pinky | Top-left corner |
| 🩵 Inky | Bottom-right corner |
| 🟠 Clyde | Bottom-left corner |

#### 🔴 Chase Phase
Each ghost uses a **unique targeting algorithm** to hunt Pac-Man. This is what gives them their distinct personalities:

| Ghost | Nickname | Chase Behaviour |
|---|---|---|
| 🔴 **Blinky** | Shadow | Directly targets Pac-Man's **current tile** — relentless pursuer |
| 🩷 **Pinky** | Speedy | Targets **4 tiles ahead** of Pac-Man's movement direction — tries to cut him off |
| 🩵 **Inky** | Bashful | Uses a **vector calculation** involving both Pac-Man's position and Blinky's position — unpredictable |
| 🟠 **Clyde** | Pokey | Chases when **far** from Pac-Man, switches to Scatter when **closer than 8 tiles** — erratic behaviour near Pac-Man |

#### 😨 Frightened Phase
Triggered when Pac-Man eats a **Power Pellet**. All ghosts:
- Turn **blue** and move at reduced speed
- Choose **random valid directions** at intersections instead of targeting
- **Flash white** shortly before the phase ends as a warning
- Can be eaten by Pac-Man for bonus points
- Return to their previous phase (Chase or Scatter) once Frightened ends

### Ghost House
At the start of each life, ghosts exit from the **ghost house** in the centre of the maze in a set order. Blinky exits immediately, the others are released over time based on a dot counter.

---

## 🏗️ Architecture

The game is built around a clean **Autoload (singleton) system** with centralised scene management.

### Autoloads

| Autoload | Script | Responsibility |
|---|---|---|
| `GameManager` | `game_manager.gd` | Score, highscore, lives, level, coin counter, game signals |
| `GameStateManager` | `game_state_manager.gd` | Scene switching via state ID |
| `Leaderboard` | `SupabaseLeaderboard.gd` | Supabase connection, player auth, score submission |
| `DevExitGame` | `DEV__exit_game.gd` | Dev shortcuts (exit game, force lives to 0) |

### Gamestates

```
0 → title_screen.tscn    (Title / Main Menu)
1 → Leaderboard.tscn     (Register & Login Screen)
2 → level.tscn           (Active Game)
```

### Signal Flow

```
level.tscn
  └─→ GameManager.GameOver()
           │
           ├─→ emit gameOver(score, level)
           │         └─→ Leaderboard._on_game_over()   [auto-connected via Autoload]
           │                   └─→ Supabase PATCH      [only if score ≥ 100 and new highscore]
           │
           └─→ GameStateManager.updategamestate(0)     [back to Title Screen]
```

### Project Structure

```
ol---pac-man-remade/
├── scenes/
│   ├── title_screen.tscn          ← Main Menu with animated Pac-Man
│   ├── Leaderboard.tscn           ← Register & Login Screen
│   ├── level.tscn                 ← Active Game (TileMap, dots, ghosts, UI)
│   ├── globals.tscn               ← Autoload container
│   ├── pac_man.tscn               ← Pac-Man scene with collision system
│   ├── pac_man_(unplayable).tscn  ← Decorative title screen Pac-Man
│   ├── ghost_test.tscn            ← Ghost pathfinding prototype
│   └── point.tscn                 ← Dot / Power Pellet scene
├── scripts/
│   ├── game_manager.gd            ← Autoload: score, lives, level, signals
│   ├── game_state_manager.gd      ← Autoload: scene switching
│   ├── SupabaseLeaderboard.gd     ← Autoload: online leaderboard & auth
│   ├── DEV__exit_game.gd          ← Autoload: dev tools
│   ├── LeaderboardUI_example.gd   ← Register/Login UI logic
│   ├── pac_man.gd                 ← Pac-Man movement & collision
│   ├── pac_man_(unplayable).gd    ← Title screen animation
│   ├── ghost_test.gd              ← Ghost AI pathfinding (WIP)
│   ├── points.gd                  ← Dot collection & scoring
│   ├── coin_collector.gd          ← Pac-Man coin hitbox
│   ├── map_and_teleporters.gd     ← Tunnel teleporter logic
│   ├── lower_ui.gd                ← Lives & level icons
│   ├── score_texts.gd             ← Score / highscore display
│   └── start_game.gd              ← Title screen start button
├── assets/
│   ├── fonts/                     ← PixelOperator8 (regular + bold)
│   └── sprites/
│       ├── PacMan/                ← Directional + death animations
│       ├── button/                ← UI button states
│       ├── levels/                ← Level indicator icons (1–19)
│       ├── lives/                 ← Life counter icons (0–5)
│       ├── points/                ← Dot sprites (small, large, empty)
│       ├── pacman_map.png         ← Maze background
│       └── map_colors.png         ← TileSet atlas
├── exports/
│   ├── OL - PacMan Remade.exe     ← Windows build
│   └── OL - PacMan Remade.html    ← Web build
└── OL - Bilder & Vids/            ← Screenshots & recordings
```

---

## 🏆 Online Leaderboard System

Built on **Supabase (PostgreSQL)** with a fully custom player authentication system — no third-party auth library, no Supabase Auth.

### Player Accounts (Arcade Style)

- **Register** with a name and password → tag auto-assigned (`gabriel` → `gabriel#00`, if taken → `gabriel#01`, etc.)
- **Login** by name or full tag + password
- **Auto-login** on subsequent launches — credentials saved locally and verified against Supabase every time
- All score writes are **authenticated server-side** via a Postgres RPC function that verifies the password before touching any data

### Score Submission Rules

The client only submits a score if:
1. `score ≥ 100` — entries below 100 are deleted by the auto-cleanup job anyway
2. `score > current highscore` — no unnecessary writes to the database

### Database Structure

```
players
  id        BIGINT   PK  auto-increment
  name      TEXT         e.g. "gabriel"
  tag       TEXT         e.g. "gabriel#00"  (unique)
  password  TEXT

leaderboard
  id              BIGINT    PK
  name            TEXT
  score           INTEGER
  level           INTEGER
  owner_id        BIGINT  → players.id
  aufgestellt_am  TIMESTAMPTZ

leaderboard_top10          ← refreshed snapshot every 15 seconds
  rank         INTEGER  PK
  id           BIGINT
  name         TEXT
  score        INTEGER
  level        INTEGER
  owner_id     BIGINT
  last_updated TIMESTAMPTZ
```

### Automated Database Jobs (pg_cron)

| Job | Interval | What it does |
|---|---|---|
| `leaderboard_cleanup` | Every 15 sec (→ 1 min in production) | Deletes all entries with `score < 100` |
| `top10_refresh` | Every 15 sec (→ 1 min in production) | Rebuilds the `leaderboard_top10` snapshot |

### Local Persistence

| Platform | Storage |
|---|---|
| Windows / Linux / Mac | `user://leaderboard_player.json` |
| Android / iOS | Internal app storage via `user://` |
| Web (HTML5 Export) | `localStorage` via `JavaScriptBridge` |

---

## 🔧 Tech Stack

<div align="center">

| | Technology | Usage |
|---|---|---|
| 🎮 | **Godot 4.6.1** | Game engine |
| 📝 | **GDScript** | 100% of game logic |
| 🖥️ | **OpenGL 3.3 Compatibility** | Renderer |
| 🗄️ | **Supabase** | PostgreSQL database + REST API |
| ⏰ | **pg_cron** | Scheduled cleanup & snapshot jobs |
| 🔀 | **GitHub** | Version control |

</div>

---

<div align="center">

Made with ❤️ by **GabrielXP9908**  
*Remake of the 1980 Namco arcade classic*

</div>