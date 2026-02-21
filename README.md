# dotfiles

managed configs for personal and work machines. setup scripts create symlinks from `~/` into this repo so edits in-place are tracked by `git`.

## structure

```
dotfiles/
├── common/            # shared across both machines
│   ├── .gitconfig
│   └── ghostty/
│       └── config
├── personal/          # personal machine configs
│   ├── .zshrc
│   ├── vscode/
│   │   ├── settings.json
│   │   └── extensions.txt
│   └── claude/
│       ├── settings.json
│       └── claude_desktop_config.json
├── work/              # work machine configs
│   ├── .zshrc
│   ├── vscode/
│   │   ├── settings.json
│   │   ├── keybindings.json
│   │   └── extensions.txt
│   ├── claude/
│   │   ├── settings.json
│   │   └── claude_desktop_config.json
│   └── arc/           # arc browser (snapshot, not symlinked)
│       ├── preferences.plist
│       └── StorableSidebar.json
└── scripts/
    ├── setup.sh
    ├── arc-export.sh
    └── arc-import.sh
```

## setting up a new machine

1. clone the repo:
   ```sh
   git clone https://github.com/ali-mir/dotfiles.git ~/dev/dotfiles
   ```

2. run the setup script with your chosen profile:
   ```sh
   chmod +x ~/dev/dotfiles/scripts/setup.sh

   # personal machine
   ~/dev/dotfiles/scripts/setup.sh personal

   # work machine
   ~/dev/dotfiles/scripts/setup.sh work
   ```

the script will back up any existing non-symlink files as `<file>.bak` before creating symlinks.

## what each script links

| Symlink | Target |
|---|---|
| `~/.zshrc` | `personal/.zshrc` or `work/.zshrc` |
| `~/.gitconfig` | `common/.gitconfig` (shared) |
| `~/Library/Application Support/Code/User/settings.json` | `personal/vscode/settings.json` or `work/vscode/settings.json` |
| `~/Library/Application Support/Code/User/keybindings.json` | `personal/vscode/keybindings.json` or `work/vscode/keybindings.json` |
| `~/Library/Application Support/com.mitchellh.ghostty/config` | `common/ghostty/config` (shared) |
| `~/.claude/settings.json` | `personal/claude/settings.json` or `work/claude/settings.json` |
| `~/Library/Application Support/Claude/claude_desktop_config.json` | `personal/claude/claude_desktop_config.json` or `work/claude/claude_desktop_config.json` |

## adding a new config file

1. copy the file into the right profile directory (`personal/` or `work/`), or `common/` if shared.
2. add a `backup_and_link` call to `scripts/setup.sh`.
3. commit and push.

## vscode extensions

each profile has an `extensions.txt` listing installed extensions. the setup script installs them automatically via `code --install-extension`.

to update the list after installing new extensions:
```sh
code --list-extensions > ~/dev/dotfiles/work/vscode/extensions.txt
# or for personal
code --list-extensions > ~/dev/dotfiles/personal/vscode/extensions.txt
```

## arc browser (work only)

arc actively writes to its config files, so symlinks don't work. instead, use snapshot-based export/import scripts.

**export** (save current arc state to the repo):
```sh
~/dev/dotfiles/scripts/arc-export.sh
```

**import** (restore on a new machine):
```sh
# make sure to quit Arc first
~/dev/dotfiles/scripts/arc-import.sh
```

this captures:
- **preferences** — auto-archive threshold, hover cards, auto-PiP, site-specific settings, etc.
- **sidebar** — all spaces, pinned tabs, folders, and links

the import script backs up any existing Arc files as `.bak` before overwriting and refuses to run while arc is open.

re-run `arc-export.sh` and commit whenever you want to save a new snapshot.

## verification

after running a setup script:
```sh
ls -la ~/.zshrc ~/.gitconfig
ls -la "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
ls -la "$HOME/Library/Application Support/Code/User/settings.json"
ls -la "$HOME/Library/Application Support/Code/User/keybindings.json"
ls -la ~/.claude/settings.json
ls -la "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
```

all should show symlinks pointing into the dotfiles repo.
