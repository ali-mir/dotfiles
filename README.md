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
│   └── vscode/
│       └── settings.json
├── work/              # work machine configs
│   ├── .zshrc
│   └── vscode/
│       └── settings.json
└── scripts/
    └── setup.sh
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
| `~/Library/Application Support/com.mitchellh.ghostty/config` | `common/ghostty/config` (shared) |

## adding a new config file

1. copy the file into the right profile directory (`personal/` or `work/`), or `common/` if shared.
2. add a `backup_and_link` call to `scripts/setup.sh`.
3. commit and push.

## verification

after running a setup script:
```sh
ls -la ~/.zshrc ~/.gitconfig
ls -la "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
ls -la "$HOME/Library/Application Support/Code/User/settings.json"
```

all four should show symlinks pointing into the dotfiles repo.
