# dotfiles

managed configs for personal and work machines. setup scripts create symlinks from `~/` into this repo so edits in-place are tracked by `git`.

## structure

```
dotfiles/
├── common/            # shared across all machines
│   ├── .gitconfig
│   ├── bin/           # ws-* scripts shared by every profile
│   │   ├── ws
│   │   └── ws-help
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
│   ├── .tmux.conf
│   ├── .workstreams.default
│   ├── bin/
│   │   ├── ws-new
│   │   ├── ws-kill
│   │   └── ws-list
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
│       │   ├── ws-new
│       │   ├── ws-kill
│       │   └── ws-list
│       ├── vscode/
│       │   └── settings.json
│       └── claude/
│           ├── settings.json
│           └── CLAUDE.md   # global instructions
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

### workstream scripts (personal, work-linux)

every `ws*` file in `common/bin/` and `<profile>/bin/` is linked into `~/bin/`.
the glob means a new script is picked up on the next `setup.sh` run with no
edit to the script itself; a profile script shadows a common one of the same name.

| Symlink | Target |
|---|---|
| `~/bin/ws` | `common/bin/ws` |
| `~/bin/ws-help` | `common/bin/ws-help` |
| `~/bin/ws-new` | `<profile>/bin/ws-new` |
| `~/bin/ws-kill` | `<profile>/bin/ws-kill` |
| `~/bin/ws-list` | `<profile>/bin/ws-list` |
| `~/.workstreams` | copied from `<profile>/.workstreams.default` (not symlinked) |

`ws` and `ws-help` are shared. `ws-new`/`ws-kill`/`ws-list` stay per-profile
because the two profiles do genuinely different things: personal points a tmux
session at a directory under `~/dev`, work-linux creates a mongo git worktree
with a venv and cleans up bazel caches on kill. `ws-help` detects which by
checking whether `~/mongo` is a git repo, and documents only the flags that
profile actually implements.

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
| `~/TMUX.md` | `work/linux/TMUX.md` |
| `~/.vscode-server/data/Machine/settings.json` | `work/linux/vscode/settings.json` |

(workstream scripts are covered in the section above.)

## adding a new config file

1. copy the file into the right directory (`common/`, `personal/`, `work/macos/`, or `work/linux/`).
2. add a `backup_and_link` call to `scripts/setup.sh`. (exception: a new `ws*`
   script in `common/bin/` or `<profile>/bin/` is linked automatically — no edit needed.)
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
ls -la ~/bin/ws*
```

symlinks should point into the dotfiles repo. `~/.workstreams` is a regular file (copied from default on first setup, then managed locally).
