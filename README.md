# Itero

Personal system provisioner and dotfile manager.

## Install

```bash
git clone https://github.com/aleksa-sukovic/itero ~/.local/share/itero
~/.local/share/itero/bin/itero
```

On first run, itero will create a `.env` file from `.env.example` and prompt you to fill in machine-specific values. After editing `.env`, it is recommended to proceed with incremental setup, restarting the system after each step:

```
ITERO_COMPONENTS=common,nvidia,wezterm,starship,fonts,shell itero
ITERO_COMPONENTS=mise,nvim,tmux,yazi,lazygit,docker,lazydocker itero
ITERO_COMPONENTS=apps,gitkraken,vscode,fastfetch,btop,vicinae itero
ITERO_COMPONENTS=snapshots,syncthing,rclone itero
ITERO_COMPONENTS=theme,gnome itero
```

## Partition Setup

Before installing, set up your disk partitions following these:

- **`/boot/efi`** (512 MB) - EFI system partition for UEFI boot (FAT32)
- **`/`** (50-100 GB minimum) - Root partition for system files (btrfs)
- **`/home`** (remaining space) - User data partition (ext4)
- **swap** (optional) - For systems with ≤8 GB RAM, use swap equal to RAM size; for 8-16 GB RAM, use half the RAM size; for >16 GB RAM, swap is optional unless hibernation is needed (then use RAM size)

### Selective Install

You can install only a selection of itero's features:

```bash
ITERO_COMPONENTS=common,gnome,fonts itero
```

## Update

```bash
cd ~/.local/share/itero && git pull && itero
```

## Themes

```bash
itero-theme                    # interactive picker
itero-theme catppuccin-mocha   # set directly
itero-theme --list             # list available
itero-theme --current          # show current
```

### Adding a new theme

1. Create `themes/<name>/palette.toml` as the single color source:
    - Include base palette keys (`rosewater`, `blue`, `base`, `text`, etc.)
    - Include app-facing keys used by templates (`background`, `foreground`, `color0..color15`, etc.)
    - `accent` is resolved dynamically from the system accent color
2. Add static files (e.g., `neovim.lua`, `wezterm.lua`, `yazi.toml`, etc.)

## Migrations

Migrations handle one-time system changes that shouldn't run again (package installs,
service configuration, destructive operations). They run once and are tracked in
`~/.local/state/itero/migrations/`.

Naming convention: `YYYY-MM-DD-NN.sh` (e.g. `2025-07-20-01.sh`).

To add a migration, create a new file in `migrations/` and commit. On existing machines
it runs once on the next `itero` invocation. Fresh installs skip all existing migrations.

## Post-Install Setup

Most dependencies are automatically installed when running `itero`. Few require further manual setup.

### GNOME

GNOME settings are stored in `config/gnome/dconf.tpl.ini` and applied automatically during `itero` runs. To apply manually, either run `itero-gnome load` or alternatively `ITERO_COMPONENTS=gnome itero` to run only the GNOME component. To capture a new setting, run `dconf watch /` while changing settings in GNOME, then add the relevant keys to the template. To add a new extension, add its identifier to the `GNOME_EXTENSIONS` array in `install/gnome.sh` and to the `enabled-extensions` list in the dconf template.

### Zotero

The current Zotero setup using custom plugins: [ZotMoov](https://github.com/wileyyugioh/zotmoov), [Zutilo utility for Zotero](https://github.com/wshanks/Zutilo). Download and install these manually. Next, setup WebDAV sync with Rivendell server (c.f., Preferences -> Sync -> WebDAV). Make sure you also change the filename format to `{{ firstCreator suffix=" - " }}{{ year suffix=" - " }}{{ title truncate="100" }}` (c.f., Preferences -> General -> Customize Filename Format). Lastly, configure the move/copy location of ZotMoov plugin (c.f., Preferences -> ZotMoov). This will ensure that all attachments (1) are stored via WebDAV and (2) are automatically moved to another location in their raw format (e.g., PDFs, images, etc.) instead of Zotero's default storage format.

### Machine-Specific Configuration

Local files (`~/.zshrc.local`, `~/.functions.local`) are created from example templates on first
run and live directly in `$HOME` as real files. Edit them in place for machine-specific settings.

## Structure

```
bin/         User commands (on $PATH)
lib/         Shared bash helpers
install/     Idempotent install scripts (run every time)
config/      Dotfiles organized by app (.tpl.* files are templates)
themes/      Theme palette definitions (palette.toml), templates, and static files
wallpapers/  Optional wallpapers for themes
migrations/  One-time system change scripts
```

## References

Inspired by my previous Ansible-based setup for [Arch](https://github.com/aleksa-sukovic/restituto-arch-ansible) and [Ubuntu](https://github.com/aleksa-sukovic/restituto-ubuntu-ansible). Wallpapers and theme inspiration from the amazing [Catppuccin](https://github.com/catppuccin) and [Omarchy](https://github.com/basecamp/omarchy) projects.
