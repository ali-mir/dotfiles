# Global instructions

## Compilation — targeted formatting and unit tests allowed; full builds defer to Ali

Coding agents may run targeted formatting and individual unit tests, including
the compilation needed for those targets. Ali owns full-server and broad build
steps and runs them manually. This applies to every project, worktree, agent,
and delegated subagent.

- `bazel run format` and `bazel run +<unit-test-target>` are explicitly allowed,
  as are their `bazelisk` equivalents. These commands may build missing or stale
  dependencies needed for the formatter or the selected unit test; existing
  binaries are not required.
- Keep unit-test commands scoped to individual unit-test targets. Do not use
  wildcard targets or broad test suites to build the entire server indirectly.
- Never run full-server or broad builds such as
  `bazel build --dbg install-dist-test`, distribution/install targets, or their
  equivalents through another build system, wrapper, background job, or subagent.
  Other compilation outside the targeted formatting/unit-test allowance must
  be deferred to Ali. Requests to implement, fix, test, or work autonomously do
  not authorize full-server builds.
- JavaScript tests with resmoke are allowed when they use already-built binaries
  and do not trigger server compilation. Read-only Bazel inspection is allowed.
- Keep concurrency modest, check available resources before resource-heavy work,
  and ask Ali before work likely to tax the machine. Do not run multiple builds
  concurrently or compete with Ali's full-server build.
- When a build outside the allowance is needed, give Ali the exact working
  directory and proposed compile command, then wait for his results. Do not
  request tool approval to run it yourself or claim compilation/tests passed
  without actual results.
- Do not bypass compile-deny policies or disguise full-server builds as
  formatting or unit-test commands.

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
