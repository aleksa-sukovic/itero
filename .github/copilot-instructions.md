# Overview

Itero is a collection of scripts and configuration files for bootstrapping a new Linux installation based on Fedora.

# Style Guide

- 4 spaces for indentation.
- Use snake_case for variable names.
- Code comments start with a capital letter and end without a period, unless multiple sentences are needed.
- Function comments start with a capital letter, end with a period and are preferably a single sentence.
- Prefer double quotes for strings, where possible.
- Prefer simple bash script and avoid complex commands that are hard to read and maintain.
- Avoid large doc-style comments across the codebase. Prefer small comments only when necessary.

# Structure and Function

- `bin/` contains user commands that are on the system `$PATH`. All commands are prefixed with `itero-` (e.g., `itero-theme`).
- `lib/` contains shared bash helper functions.
- `config/` contains dotfiles organized by app. Files with `.tpl.` are templates that are processed before being symlinked to their final location.
- `install/` contains idempotent install scripts for packages that run every time `itero` is invoked.
- `migrations/` contains one-time system changes that shouldn't run again (meant to upgrade existing machines, not for fresh installs).
- `themes/` contains color schemes and static config files for various apps. Each theme has its own subdirectory.
- `wallpapers/` contains optional wallpapers.
- Templates have `.tpl` in their filename (before the file type extension). The `compile_template` function replaces `{{ var_name }}` with the value of the corresponding variable defined either in the passed variables file or in the shell environment. Output is written to the same path but without `.tpl` in the filename and should be git ignored.

# Development

- All debugging commands (e.g., reading logs) should be run by you.
- Always follow the existing code-style and structure of the project. If you notice any inconsistencies, please fix them as part of your contribution.
- Do NOT auto-commit changes without my approval.
