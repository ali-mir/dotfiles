# claude code config (work linux)

## settings.template.json

seed for `~/.claude/settings.json` on this box. `scripts/setup.sh` **copies** it on first run only —
if `~/.claude/settings.json` already exists, setup leaves it alone.

it is copied rather than symlinked because `fireconnect` rewrites the live file in place and stores
the Fireworks API key in it. the key has to sit next to `ANTHROPIC_BASE_URL` in the same file
(a user-level `settings.local.json` is not read as a settings source for it, so requests 401), so
the live copy holds a secret and is gitignored. see `scripts/setup-fireconnect.sh`.

editing the template does **not** update the live file. to pick up template changes, diff the two by
hand and copy across the bits you want.

### what each block does

| key | meaning |
| --- | --- |
| `effortLevel` | default thinking effort for new sessions. |
| `permissions.deny` | blocks `WebSearch` / `WebFetch` — this box has no browser and egress is restricted, so web tools only ever waste a turn. |
| `modelPicker.options` | the `/model` menu. mixes Anthropic models with Fireworks serverless models reachable through the fireconnect proxy. `label` is what shows in the picker, `description` is the line under it. |
| `modelPicker.replaceBuiltInOptions` | `true` hides the stock Anthropic-only list, so the picker shows only the entries above. |
| `attribution.commit` / `.pr` | empty strings strip the "generated with Claude Code" / co-author trailers from commits and PRs. |
| `model` | model new sessions start on. the org default (`Sonnet 5`) can override this on restart. |

### conventions inside `modelPicker.options`

- `[1m]` suffix on a model id selects its 1M-context variant.
- `👀` = handles images; `🙈` = text only.
- `[Experimental]` in the label = on the Fireworks side it may disappear or change pricing without notice.
- `description` carries per-Mtok input / output / cached-input pricing, kept manually — re-check it against
  the Fireworks pricing page before trusting a cost estimate.
