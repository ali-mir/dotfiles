# dotfiles

Managed configs for personal and work machines. Setup scripts create symlinks from `~/` into this repo so edits in-place are tracked by git.

## Structure

```
dotfiles/
├── personal/          # Personal machine configs
│   ├── .zshrc
│   └── vscode/
│       └── settings.json
├── work/              # Work machine configs
│   ├── .zshrc
│   └── vscode/
│       └── settings.json
├── common/            # Shared across both machines
│   ├── .gitconfig
│   └── ghostty/
│       └── config
└── scripts/
    └── setup.sh
```

## Setting up a new machine

1. Clone the repo:
   ```sh
   git clone https://github.com/your-username/dotfiles.git ~/dev/dotfiles
   ```

2. Run the setup script with your profile:
   ```sh
   chmod +x ~/dev/dotfiles/scripts/setup.sh

   # Personal machine
   ~/dev/dotfiles/scripts/setup.sh personal

   # Work machine
   ~/dev/dotfiles/scripts/setup.sh work
   ```

The script will back up any existing non-symlink files as `<file>.bak` before creating symlinks.

## What each script links

| Symlink | Target |
|---|---|
| `~/.zshrc` | `personal/` or `work/.zshrc` |
| `~/.gitconfig` | `common/.gitconfig` (shared) |
| `~/Library/Application Support/Code/User/settings.json` | `personal/` or `work/vscode/settings.json` |
| `~/Library/Application Support/com.mitchellh.ghostty/config` | `common/ghostty/config` (shared) |

## Adding a new config file

1. Copy the file into the right profile directory (`personal/` or `work/`), or `common/` if shared.
2. Add a `backup_and_link` call to `scripts/setup.sh`.
3. Commit and push.

## Ghostty

Ghostty config lives in `common/ghostty/config` and is shared between personal and work machines. Editing `~/Library/Application Support/com.mitchellh.ghostty/config` edits the file in the repo directly.

## Verification

After running a setup script:
```sh
ls -la ~/.zshrc ~/.gitconfig
ls -la "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
ls -la "$HOME/Library/Application Support/Code/User/settings.json"
```

All four should show symlinks pointing into the dotfiles repo.
