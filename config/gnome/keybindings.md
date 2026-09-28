# GNOME keybindings

Itero uses `Super` for window and application actions, `Super+Shift` for alternate
applications and web apps, and `Super+Ctrl` for system and window-manager actions.

## System

| Shortcut           | Action                  |
| ------------------ | ----------------------- |
| `Super+,`          | Open GNOME Settings     |
| `Super+.`          | Toggle Do Not Disturb   |
| `Super+/`          | Open Quick Settings     |
| `Super+M`          | Open notifications      |
| `Super+S`          | Open the overview       |
| `Super+Space`      | Open Vicinae            |
| `Super+Ctrl+/`     | Lock the screen         |
| `Super+Ctrl+E`     | Open the emoji picker   |
| `Super+Ctrl+V`     | Open clipboard history  |
| `Super+Ctrl+Alt+V` | Clear clipboard history |
| `Super+Ctrl+C`     | Capture a screenshot    |
| `Super+Shift+/`    | Cycle the wallpaper     |

## Applications

| Shortcut             | Action                                          |
| -------------------- | ----------------------------------------------- |
| `Super+Return`       | Open WezTerm                                    |
| `Super+Shift+Return` | Open a Tmux terminal                            |
| `Super+Shift+T`      | Open Btop                                       |
| `Super+E`            | Open Nautilus                                   |
| `Super+Shift+E`      | Open Nautilus in the terminal working directory |
| `Super+Shift+Alt+E`  | Open Yazi                                       |
| `Super+N`            | Open the scratch pad                            |
| `Super+Shift+O`      | Open Obsidian                                   |
| `Super+B`            | Open Firefox                                    |
| `Super+Shift+B`      | Open a private Firefox window                   |
| `Super+Shift+A`      | Open Gemini                                     |
| `Super+Shift+R`      | Open Reddit                                     |
| `Super+Shift+X`      | Open X                                          |
| `Super+Shift+Y`      | Open YouTube                                    |

## Window management

| Shortcut                                            | Action                                               |
| --------------------------------------------------- | ---------------------------------------------------- |
| `Super+G`                                           | Toggle the focused window between tiled and floating |
| `Super+Shift+G` or `Super+Keypad Enter`             | Enter interactive tiling mode                        |
| `Super+Ctrl+G`                                      | Cycle the default mode for new windows               |
| `Super+F`                                           | Maximize the focused window while preserving gaps    |
| `Super+Q`                                           | Close the focused window                             |
| `Super+Shift+S`                                     | Toggle stacking mode                                 |
| `Super+Shift+Ctrl+S`                                | Stack the focused window                             |
| `Super+Shift+Alt+S`                                 | Unstack the focused window                           |
| `Super+Shift+Alt+H` / `L`                           | Move the focused stack tab left / right              |
| `Super+Ctrl+R`                                      | Refresh the tiling layout                            |
| `Super+Shift+M`                                     | Toggle the top bar                                   |
| `Super+1`–`5`                                       | Switch to workspace 1–5                              |
| `Super+Shift+1`–`5`                                 | Move the focused window to workspace 1–5             |
| `Super+Grave`                                       | Switch application group                             |
| `Super+Shift+Grave`                                 | Switch application group backwards                   |
| `Super` + arrow keys or `H` / `J` / `K` / `L`       | Focus a window by direction                          |
| `Super+Shift` + arrow keys or `H` / `J` / `K` / `L` | Move the focused window to a monitor                 |
| `Super+Ctrl` + `H` / `J` / `K` / `L`                | Move the pointer to a monitor                        |

`Super+G` affects only the focused window; Itero WM no longer binds a global
auto-tiling toggle.

### In interactive tiling mode

| Shortcut                                      | Action                    |
| --------------------------------------------- | ------------------------- |
| `Enter`                                       | Accept tiling changes     |
| `Escape`                                      | Reject tiling changes     |
| Arrow keys or `H` / `J` / `K` / `L`           | Move the focused window   |
| `Shift` + arrow keys or `H` / `J` / `K` / `L` | Resize the focused window |
| `Ctrl` + arrow keys or `H` / `J` / `K` / `L`  | Swap the focused window   |
| `O`                                           | Toggle tiling orientation |
| `S`                                           | Toggle stacking mode      |

## Input and display

| Shortcut                       | Action                                               |
| ------------------------------ | ---------------------------------------------------- |
| `Alt+Space`                    | Switch input source                                  |
| `Alt+Shift+Space`              | Switch input source backwards                        |
| `Brightness Up` / `Down`       | Adjust external display brightness                   |
| `Shift+Brightness Up` / `Down` | Set external display brightness to maximum / minimum |
