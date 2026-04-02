# workstream workflow

each workstream gets its own tmux session. sessions are recreated on reboot from `~/.workstreams`.

## commands

### create a workstream

```sh
# mongo worktree off master (most common)
ws-new my-feature

# mongo worktree off an older branch
ws-new my-backport --base v8.0

# non-mongo directory
ws-new sls --dir ~/sls/storage
```

### kill a workstream

```sh
ws-kill my-feature
```

for mongo worktrees, this also removes the worktree, deletes the branch, and cleans up bazel cache. you'll get a confirmation prompt before anything is deleted.

### switch sessions

```sh
ws          # session picker (numbered menu outside tmux, choose-tree inside)
```

or use tmux directly: `Ctrl-a s` to pick from the session list.

### list workstreams

```sh
ws-list     # shows all configured workstreams and whether sessions are alive
```

## how it works

- `~/.workstreams` stores `name:directory:flags` per line
- on SSH login, `.zshrc` recreates any missing sessions from this file, then runs `ws` to attach
- `~/bin/ws-new` and `~/bin/ws-kill` manage the full lifecycle

## adding windows within a session

once attached to a session, use normal tmux commands:

- `Ctrl-a c` — new window
- `Ctrl-a ,` — rename window
- `Ctrl-a n` / `Ctrl-a p` — next/previous window
- `Ctrl-a <number>` — jump to window by number

## config file format

```
# name:directory:flags
# flags: venv (activate venv/bin/activate), worktree (mongo git worktree)
mongo:~/mongo:venv
my-feature:~/my-feature:venv,worktree
sls:~/sls/storage:
```
