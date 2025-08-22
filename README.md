# HordeEngine

An experimental back-end engine for Garry’s Mod that aims to add large — frankly absurd — quantities of zombies into the game with minimal performance impact.

---

## Features
- Minimal test module with `hordeengine.status2()` function for quick load checks.
- Supports both client (`gmcl_hordeengine_win64.dll`) and server (`gmsv_hordeengine_win64.dll`) builds.
- Designed to push GMod performance limits while staying lightweight.

---

## Build Instructions
1. Open the project in **Visual Studio 2022**.
2. Build either `gmcl_hordeengine_win64` or `gmsv_hordeengine_win64` in **Release x64**.
3. Copy the DLLs into:
garrysmod/lua/bin/

yaml
Copy
Edit
Or run the included **PowerShell deploy script** to automatically handle backups and deployment.

---

## Debug / Testing
Inside Garry’s Mod console:
```lua
lua_run print(pcall(require, "hordeengine"))
lua_run print(hordeengine.status2())
Expected output:

arduino
Copy
Edit
true
HordeEngine_OK
Development Workflow
Git Workflow
This repo includes helper scripts for quick syncing with GitHub:

push.bat
Stages all changes, commits, and pushes to GitHub.
Usage: double-click push.bat, enter a commit message if prompted, and it’s done.

pull.bat
Fetches and rebases the latest changes from GitHub onto your local branch.
Usage: double-click pull.bat before starting new work to stay up to date.

Notes
Repo marked as a safe directory, so no “dubious ownership” warnings.

Authentication handled via GitHub Personal Access Token (PAT) stored in Windows Credential Manager.

Line endings normalized via .gitattributes for cross-platform consistency.

Roadmap
Expand from minimal API → full zombie-spawn backend.

Optimize entity updates for massive hordes.

Add modular extensions for AI behaviors.

License
MIT License — free to use, modify, and distribute.

yaml
Copy
Edit

---

✅ That gives you:  
- Project description  
- Build steps  
- In-game test commands  
- Git workflow docs (`push.bat` / `pull.bat`)  
- Roadmap + License  

