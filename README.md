# Itero

Personal system provisioner and dotfile manager.

## Install

```bash
git clone https://github.com/aleksa-sukovic/itero ~/.local/share/itero
~/.local/share/itero/bin/itero
```

On first run, Itero creates an `.env` file from `.env.example` and prompts for machine-specific values. After editing `.env`, proceed with incremental setup in the following order, restarting the system after each step:

```bash
ITC=common,nvidia,wezterm,kitty,starship,fonts,shell itero
ITC=mise,nvim,tmux,yazi,lazygit,docker,lazydocker itero
ITC=apps,bruno,gitkraken,vscode,fastfetch,btop,vicinae itero
ITC=snapshots,syncthing,rclone itero
ITC=theme,gnome,gdm itero
```

Every command in `bin/` supports `--help` with its usage and available options.

### macOS setup

On macOS, Itero supports a terminal-focused setup rather than full machine provisioning. Run the following component batches in order:

```bash
ITC=common,wezterm,kitty,starship,fonts,shell itero
ITC=mise,nvim,tmux,yazi,lazygit,lazydocker itero
ITC=fastfetch,btop,bruno itero
ITC=theme itero
```

To manage a `/work` bind mount, set `ITERO_WORKDIR` in `.env` to the directory that should appear at `/work`. Itero configures `/work` through `/etc/synthetic.conf`, which takes effect after a reboot. To update all components at once, run:

```bash
ITC=common,wezterm,kitty,starship,fonts,shell,mise,nvim,tmux,yazi,lazygit,lazydocker,fastfetch,btop,bruno,theme itero
```

## Partition Setup

Before installing, set up your disk partitions following these:

- **`/boot/efi`** (512 MB) - EFI system partition for UEFI boot (FAT32)
- **`/`** (50-100 GB minimum) - Root partition for system files (btrfs)
- **`/home`** (remaining space) - User data partition (ext4)
- **swap** (optional) - For systems with ≤8 GB RAM, use swap equal to RAM size; for 8-16 GB RAM, use half the RAM size; for >16 GB RAM, swap is optional unless hibernation is needed (then use RAM size)

### Selective Install

Use `itero --help` to see the available components. Optional packages are skipped by both a normal full run and `ITC=all`; select them explicitly to install.

## Update

`itero-update` updates system and Flatpak packages. Run `itero` separately to update Itero itself and apply its configuration or `itero --update` to force-update existing configuration files.

## Themes

`itero-theme` manages themes and accent colors. Accent colors use Itero palette names (such as `blue`, `mauve`, and `lavender`) and are synced bidirectionally with the system accent setting (GNOME/macOS). Each theme maps those names to its own palette, so the resulting color may not visually match the system's built-in accent color.

### Adding a new theme

1. Create `themes/<name>/palette.toml` as the single color source:
    - Include the accent aliases used by the system picker (`blue`, `teal`, `green`, `yellow`, `peach`, `red`, `pink`, `mauve`, and `lavender`)
    - Include app-facing keys used by templates (`background`, `foreground`, `color0..color15`, etc.)
    - `accent` is resolved dynamically from the system accent color
2. Add app assets as needed (use a `.tpl` filename for files that require template substitution)
3. Add `vicinae.conf` if the theme should map to one of Vicinae's built-in themes

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

GNOME settings are stored in `config/gnome/dconf.tpl.ini` and applied automatically during `itero` runs. To capture a new setting, run `dconf watch /` while changing settings in GNOME, then add the relevant keys to the template. To add a new extension, add its identifier to the `GNOME_EXTENSIONS` array in `install/gnome.sh` and to the `enabled-extensions` list in the dconf template.

### Zotero

The current Zotero setup using custom plugins: [ZotMoov](https://github.com/wileyyugioh/zotmoov), [Zutilo utility for Zotero](https://github.com/wshanks/Zutilo). Download and install these manually. Next, setup WebDAV sync with Rivendell server (c.f., Preferences -> Sync -> WebDAV). Make sure you also change the filename format to `{{ firstCreator suffix=" - " }}{{ year suffix=" - " }}{{ title truncate="100" }}` (c.f., Preferences -> General -> Customize Filename Format). Lastly, configure the move/copy location of ZotMoov plugin (c.f., Preferences -> ZotMoov). This will ensure that all attachments (1) are stored via WebDAV and (2) are automatically moved to another location in their raw format (e.g., PDFs, images, etc.) instead of Zotero's default storage format.

### Machine-Specific Configuration

Local files (`~/.zshrc.local`, `~/.functions.local`) are initialized from shell templates on first run and live directly in `$HOME`. Their `config/shell/*.local` counterparts inside Itero are symlinks back to the `$HOME` files.

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
