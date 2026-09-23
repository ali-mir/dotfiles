# Global instructions

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
