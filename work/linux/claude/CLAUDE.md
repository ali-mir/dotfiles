# Global instructions

## External writes — NEVER without explicit approval

Never post, create, update, or transition anything on an external system — Jira (comments,
issues, transitions, links), GitHub (PRs, comments, reviews), Slack, Confluence — unless I have
just given an explicit, unambiguous go-ahead for that specific action in my latest message.
Read-only queries are fine. An offer the agent makes is not approval; a reply that is ambiguous
or answers a different question is not approval. If there is any doubt, ask and wait. The
action being accurate, or being on my own ticket, does not make it OK.

## Jira and Evergreen — always via the devprod-mcp gateway

For ANY Jira or Evergreen task (searching/reading/creating/updating tickets, CI
patches, task logs, test results, build-failure investigation), use the
`devprod-mcp` MCP server's tools exclusively — the `jira_*` and `evg_*` (plus
`bb_*`) tool families. Do NOT use a standalone Jira MCP, a standalone Evergreen
MCP, or any other connector for these, even if one happens to be configured and
connected. `devprod-mcp` is the single canonical path; its `evg_*` tools are a
superset of the standalone Evergreen server. If devprod-mcp is not connected,
fix that (re-auth via `&headless=true`) rather than falling back to another server.

## Code review

NEVER check out or otherwise switch the working tree to the code under review (no `gh pr checkout`,
no `git checkout <branch>`, no `git switch`). Leave the checked-out branch exactly as it was found.
Read the code under review out-of-tree instead: `gh pr diff`, `gh pr view`, `gh api` for file
contents at the PR's head, or a separate worktree if a full tree is genuinely needed.
