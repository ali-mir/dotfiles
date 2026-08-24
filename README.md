# dotfiles

managed configs for personal and work machines. setup scripts create symlinks from `~/` into this repo so edits in-place are tracked by `git`.

## structure

```
dotfiles/
├── common/            # shared across all machines
│   ├── .gitconfig
│   ├── git/
│   │   └── ignore     # global gitignore
│   ├── ghostty/
│   │   └── config
│   ├── zsh-themes/
│   │   └── agnoster-custom.zsh-theme
│   └── arc/           # arc browser snapshots (encrypted)
│       ├── StorableSidebar.json.age
│       └── preferences.plist.age
├── personal/          # personal macOS configs
│   ├── .zshrc
│   ├── vscode/
│   │   ├── settings.json
│   │   └── extensions.txt
│   └── claude/
│       ├── settings.json
│       └── CLAUDE.md   # global instructions
├── work/
│   ├── macos/         # work macOS configs
│   │   ├── .zshrc
│   │   ├── vscode/
│   │   │   ├── settings.json
│   │   │   ├── keybindings.json
│   │   │   └── extensions.txt
│   │   ├── claude/
│   │   │   └── settings.json
│   │   └── ssh/
│   │       └── config
│   └── linux/         # work linux VM configs
│       ├── .zshrc
│       ├── .tmux.conf
│       ├── .workstreams.default
│       ├── bin/
│       │   ├── ws
│       │   ├── ws-new
│       │   ├── ws-kill
│       │   └── ws-list
│       ├── vscode/
│       │   └── settings.json
│       └── claude/
│           └── settings.json
└── scripts/
    ├── setup.sh
    ├── arc-export.sh
    └── arc-import.sh
```

## setting up a new machine

1. clone the repo anywhere you like — `setup.sh` resolves the repo root from its
   own path, so the location is not baked in. in practice:
   `~/dev/dotfiles` on the personal laptop, `~/dotfiles` on work machines.
   ```sh
   git clone https://github.com/ali-mir/dotfiles.git ~/dev/dotfiles
   ```

2. run the setup script with your profile:
   ```sh
   # personal macOS
   ~/dev/dotfiles/scripts/setup.sh personal

   # work macOS
   ~/dotfiles/scripts/setup.sh work-macos

   # work linux VM
   ~/dotfiles/scripts/setup.sh work-linux
   ```

the script checks the platform and refuses to run a macOS profile on linux (or vice versa). existing non-symlink files are backed up as `<file>.bak`.

## what gets linked

### all profiles (common)

| Symlink | Target |
|---|---|
| `~/.gitconfig` | `common/.gitconfig` |
| `~/.config/git/ignore` | `common/git/ignore` |
| `~/.oh-my-zsh/custom/themes/agnoster-custom.zsh-theme` | `common/zsh-themes/agnoster-custom.zsh-theme` |
| `~/.zshrc` | `<profile>/.zshrc` |
| `~/.claude/settings.json` | `<profile>/claude/settings.json` |
| `~/.claude/CLAUDE.md` | `<profile>/claude/CLAUDE.md` (linked only if the profile has one) |

### macOS profiles (personal, work-macos)

| Symlink | Target |
|---|---|
| `~/Library/.../Code/User/settings.json` | `<profile>/vscode/settings.json` |
| `~/Library/.../Code/User/keybindings.json` | `<profile>/vscode/keybindings.json` |
| `~/Library/.../com.mitchellh.ghostty/config` | `common/ghostty/config` |
| `~/.ssh/config` | `<profile>/ssh/config` |

### work-linux

| Symlink | Target |
|---|---|
| `~/.tmux.conf` | `work/linux/.tmux.conf` |
| `~/.workstreams` | copied from `work/linux/.workstreams.default` (not symlinked) |
| `~/bin/ws` | `work/linux/bin/ws` |
| `~/bin/ws-new` | `work/linux/bin/ws-new` |
| `~/bin/ws-kill` | `work/linux/bin/ws-kill` |
| `~/bin/ws-list` | `work/linux/bin/ws-list` |
| `~/.vscode-server/data/Machine/settings.json` | `work/linux/vscode/settings.json` |

## adding a new config file

1. copy the file into the right directory (`common/`, `personal/`, `work/macos/`, or `work/linux/`).
2. add a `backup_and_link` call to `scripts/setup.sh`.
3. commit and push.

## vscode extensions

each macOS profile has an `extensions.txt` listing installed extensions. the setup script installs them automatically via `code --install-extension`.

to update the list after installing new extensions:
```sh
code --list-extensions > ~/dotfiles/work/macos/vscode/extensions.txt
# or for personal laptop
code --list-extensions > ~/dev/dotfiles/personal/vscode/extensions.txt
```

## arc browser

arc actively writes to its config files, so symlinks don't work. instead, use snapshot-based export/import scripts. snapshots are stored in `common/arc/` so they can be shared across machines.

backups are encrypted with [`age`](https://github.com/FiloSottile/age) passphrase encryption — only `.age` files are committed, plaintext never touches git.

**export** (save current arc state to the repo), from the repo root:
```sh
./scripts/arc-export.sh
# prompts for a passphrase, produces StorableSidebar.json.age and preferences.plist.age
```

**import** (restore on a new machine):
```sh
# make sure to quit Arc first
./scripts/arc-import.sh
# prompts for the passphrase, decrypts to a temp location, imports, then cleans up
```

## workstream management (linux VM)

the `work-linux` profile includes tmux workstream scripts. see `~/tmux.md` for usage.

## verification

after running setup:
```sh
# all platforms
ls -la ~/.zshrc ~/.gitconfig ~/.config/git/ignore ~/.claude/settings.json ~/.claude/CLAUDE.md

# macOS
ls -la "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
ls -la "$HOME/Library/Application Support/Code/User/settings.json"
ls -la ~/.ssh/config

# linux
ls -la ~/.tmux.conf ~/.workstreams
ls -la ~/bin/ws ~/bin/ws-new ~/bin/ws-kill ~/bin/ws-list
```

symlinks should point into the dotfiles repo. `~/.workstreams` is a regular file (copied from default on first setup, then managed locally).
