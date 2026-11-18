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

## Jira and Evergreen — always via the devprod-mcp gateway

For ANY Jira or Evergreen task (searching/reading/creating/updating tickets, CI
patches, task logs, test results, build-failure investigation), use the
`devprod-mcp` MCP server's tools exclusively — the `jira_*` and `evg_*` (plus
`bb_*`) tool families. Do NOT use a standalone Jira MCP, a standalone Evergreen
MCP, or any other connector for these, even if one happens to be configured and
connected. `devprod-mcp` is the single canonical path; its `evg_*` tools are a
superset of the standalone Evergreen server. If devprod-mcp is not connected,
fix that (re-auth via the headless flow) rather than falling back to another server.

The one exception is the evergreen CLI: you may use it to generate and finalize
patches inside an autonomous loop, but only when Ali directs it. Once a patch
is running, any analysis or monitoring goes through devprod-mcp — the CLI is
for creating patches, not tracking them.
