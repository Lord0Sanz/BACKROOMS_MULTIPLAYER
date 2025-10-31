---

# BACKROOMS MULTIPLAYER

---

# BACKROOMS MULTIPLAYER DEMO

A basic local multiplayer prototype demonstrating host-client networking in Godot.

**DOWNLOAD:** [Windows](https://workupload.com/file/HspSUpHrf2c) | [Linux](https://workupload.com/file/yEGd38JetQw)

*Made by PROJEKT SANS STUDIOS*

---

## SCREENSHOTS

![Screenshot 1](https://github.com/Lord0Sanz/BACKROOMS_MULTIPLAYER/blob/main/screenshots/SS1.png?raw=true)
![Screenshot 2](https://github.com/Lord0Sanz/BACKROOMS_MULTIPLAYER/blob/main/screenshots/SS2.png?raw=true)
![Screenshot 3](https://github.com/Lord0Sanz/BACKROOMS_MULTIPLAYER/blob/main/screenshots/SS3.png?raw=true)

---

## WHAT IS THIS?

This is a simple multiplayer demo where players can:

* Host a game server
* Join as clients
* Move around in a 3D environment using WASD
* See other players with proper labels (HOST/CLIENT)

---

## HOW IT WORKS

### HOST (Server)

1. Click **"START SERVER"** - becomes Player 1
2. Gets label: **HOST** with IP **127.0.0.0**
3. Can see all connected clients
4. Controls the game session

### CLIENT (Player)

1. Click **"JOIN SERVER"** - connects to host
2. Gets label: **CLIENT** with IP **127.0.0.1** (increments for more players)
3. Can see host and other clients
4. Can move independently

---

## CONTROLS

* **WASD** - Move around
* **Mouse** - Look around
* **Left Click** - Capture mouse
* **ESC** - Release mouse

---

## TECHNICAL STUFF

**Engine:** Godot 4.5.1
**Networking:** ENet (UDP)
**Port:** 1027
**Max Players:** 8

**Assets Used:**

* Animations: Mixamo (walk/idle)
* Audio: Pixabay
* Font: DaFont

---

## FILES

* `main.gd` - Handles networking, spawning, game logic
* `player.gd` - Controls movement, camera, player behavior, player animation

---

*PROJEKT SANS STUDIOS - Basic Multiplayer Demo*

---
