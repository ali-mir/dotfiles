# Global instructions

## Compilation — NEVER; always defer to Ali

Coding agents must NEVER start local compilation. Ali owns the Bazel compile
step and runs it manually so only one build runs on this machine at a time.
This applies to every project, worktree, agent, and delegated subagent.

- Never run `bazel build` or `bazelisk build`, or compile indirectly through
  another build system, wrapper, test runner, background job, or subagent.
  Requests to implement, fix, test, or work autonomously do not authorize compilation.
- Unit tests (including Bazel unit tests) and JavaScript tests with resmoke are
  allowed when they use already-built binaries and do not trigger compilation.
  Bazel test/run/coverage may compile missing or stale targets: do not assume
  they are compile-free. If compilation would occur, or you cannot establish
  that it will not, defer that step to Ali; running existing test binaries directly
  is an option. Read-only Bazel inspection is allowed.
- Subagents and background jobs are allowed for non-compiling work. Err on the
  side of caution with resource-heavy jobs: check available resources, keep
  concurrency modest, and ask Ali before work likely to tax the machine.
- When compilation is needed, give Ali the exact working directory and proposed
  compile command, then wait for his results. Do not request tool approval to
  compile yourself or claim compilation/tests passed without actual results.
- Do not bypass or weaken compile-deny policies. Compilation remains user-only
  until Ali explicitly changes this policy.

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
