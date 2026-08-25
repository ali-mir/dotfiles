# Global instructions

## Code review

NEVER check out or otherwise switch the working tree to the code under review (no `gh pr checkout`,
no `git checkout <branch>`, no `git switch`). Leave the checked-out branch exactly as it was found.
Read the code under review out-of-tree instead: `gh pr diff`, `gh pr view`, `gh api` for file
contents at the PR's head, or a separate worktree if a full tree is genuinely needed.
