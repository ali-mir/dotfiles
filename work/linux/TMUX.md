# workstream workflow

each workstream gets its own tmux session. sessions are recreated on reboot from `~/.workstreams`.

## commands

### create a workstream

```sh
# mongo worktree off master (most common)
ws-new my-feature

# mongo worktree off an older branch
ws-new my-backport --base v8.0

# custom branch name (session name differs from git branch)
ws-new SERVER-123663-checkpoint-lag --branch ali-mir/SERVER-123663-checkpoint-lag

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

- `~/.workstreams` stores `name:directory:flags[:branch]` per line (branch is optional, only stored when it differs from name)
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
# name:directory:flags[:branch]
# flags: venv (activate venv/bin/activate), worktree (mongo git worktree)
# branch: optional, only present when git branch differs from session name
mongo:~/mongo:venv
my-feature:~/my-feature:venv,worktree
SERVER-123663:~/SERVER-123663:venv,worktree:ali-mir/SERVER-123663
sls:~/sls/storage:
```
