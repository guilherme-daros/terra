# Cosmic Defender 🚀 (LÖVE2D Example Game)

A complete, polished, zero-external-asset 2D space shooter arcade game built using **Lua**, the **[LÖVE2D](https://love2d.org/)** game engine, **JetBrains Mono Nerd Font**, and **Retro Post-Processing Shaders**!

![Engine](https://img.shields.io/badge/Engine-LÖVE2D%2011.x-pink.svg)
![Language](https://img.shields.io/badge/Language-Lua-blue.svg)
![Font](https://img.shields.io/badge/Font-JetBrainsMono%20Nerd%20Font-orange.svg)
![Shaders](https://img.shields.io/badge/Shaders-GLSL%20CRT%20%7C%20Bloom%20%7C%20Chromatic-purple.svg)

---

## 🎮 How to Play

### Controls
* **WASD** / **Arrow Keys**: Move your spaceship
* **Mouse Cursor**: Aim your ship's plasma cannon
* **Left Mouse Button** / **Spacebar**: Fire weapons
* **P** / **ESC**: Pause / Resume game (during gameplay)
* **M** / **Q**: End current run and return to Main Menu (while Paused)
* **Q** / **ESC**: Quit the game application (from Title Screen)

### 💎 Nerd Font Icons & Power-Ups
The UI uses **JetBrains Mono Nerd Font** icons for clear visual feedback:

*  **Health / Hull Repair**: Restores ship hull integrity & displays remaining lives.
* 󱐋 **Triple Laser Shot**: Equips a wide 3-way laser spread.
*  **Energy Shield**: Grants temporary invulnerability bubble (`nf-fa-shield`).

### 🌟 Gameplay Features & Visual Shaders
* **Wave Progression**: Face increasing waves of hazardous asteroids (`󰓎`) and tactical enemy Hunter Drones.
* **📺 Retro CRT & Curved Screen Shader**: Authentically emulates an 80s arcade cabinet monitor with scanlines, CRT curvature, subtle flicker, and vignette.
* **✨ Neon Bloom Shader**: Makes plasma lasers, thruster trails, and explosions intensely glow.
* **💥 Chromatic Aberration Shader**: Dynamically warps RGB channels on screen shake and asteroid explosions.
* **Procedural Sound Engine**: Synthesizes laser pew sounds, explosions, power-up chimes, and hit feedback using LÖVE's `SoundData` API in real-time.

---

## 🚀 How to Run the Game

### Prerequisites
Make sure you have **LÖVE** installed on your system:
* **Linux (Ubuntu/Debian)**: `sudo apt install love`
* **Linux (Arch/Manjaro)**: `sudo pacman -S love`
* **macOS**: `brew install love`
* **Windows**: Download installer or zip from [love2d.org](https://love2d.org/)

### Running from Terminal
Navigate to this project directory and run:

```bash
love .
```

Or pass the path directly:
```bash
love /path/to/terra
```

### Packaging as a `.love` File
To package this game into a distributable archive:

```bash
zip -9 -r CosmicDefender.love . -x "*.git*"
```
Then run it with:
```bash
love CosmicDefender.love
```

---

## 📂 Codebase Architecture

| File | Description |
| :--- | :--- |
| [`conf.lua`](file:///home/geagaa/workspace/terra/conf.lua) | LÖVE system configuration (window resolution, anti-aliasing, title). |
| [`shaders.lua`](file:///home/geagaa/workspace/terra/shaders.lua) | Post-processing GLSL shader engine (CRT scanlines/curvature, Bloom glow, Chromatic aberration). |
| [`colors.lua`](file:///home/geagaa/workspace/terra/colors.lua) | Centralized color palette manager for UI, HUD, ship, enemies, lasers, and effects. |
| [`fonts.lua`](file:///home/geagaa/workspace/terra/fonts.lua) | Typography manager for JetBrains Mono Nerd Font sizes and icon mappings. |
| [`main.lua`](file:///home/geagaa/workspace/terra/main.lua) | High-level game entrypoint, state router, and shader capture pipeline. |
| [`ui.lua`](file:///home/geagaa/workspace/terra/ui.lua) | User interface renderer for HUD health bar, score, wave, active power-ups, menu, and pause overlays. |
| [`collision.lua`](file:///home/geagaa/workspace/terra/collision.lua) | Combat physics and collision detection engine (bullet vs enemy, drone vs player, asteroid crash). |
| [`player.lua`](file:///home/geagaa/workspace/terra/player.lua) | Player spaceship physics, mouse tracking, health/shield mechanics, and weapon power-ups. |
| [`enemy.lua`](file:///home/geagaa/workspace/terra/enemy.lua) | Asteroid generation & splitting, Hunter Drone AI, wave spawner, and pixel-scanned icon power-up capsules. |
| [`bullet.lua`](file:///home/geagaa/workspace/terra/bullet.lua) | Projectile lifecycle management for player lasers and enemy plasma. |
| [`particle.lua`](file:///home/geagaa/workspace/terra/particle.lua) | Particle system for engine thrust, explosions, and power-up glimmers. |
| [`starfield.lua`](file:///home/geagaa/workspace/terra/starfield.lua) | Multi-layered parallax scrolling star background with twinkling effects. |
| [`sound.lua`](file:///home/geagaa/workspace/terra/sound.lua) | Real-time procedural audio synthesis engine generating all game SFX programmatically. |
| [`assets/fonts/`](file:///home/geagaa/workspace/terra/assets/fonts) | Embedded `JetBrainsMonoNerdFont-Regular.ttf` and `JetBrainsMonoNerdFont-Bold.ttf` font files. |

---

Enjoy playing and tweaking the game! 🌌
