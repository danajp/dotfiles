---
name: optimize-opencode-agent-models
description: >
  Audit and optimize the model assignments in this repo's oh-my-opencode agent config. Use this
  skill when asked to "optimize opencode agent models", "check my oh-my-opencode models", "are my
  agent models optimal", "update the opencode models", or after a provider ships new models. It
  reads the live `opencode models` list and the authenticated providers, matches each agent to its
  upstream role, proposes an optimal per-agent model per tier, consults the user before writing,
  then updates the correct machine-specific config file and validates every model ID.
---

# Optimize oh-my-opencode agent models

You are helping the user keep the model assignments in their oh-my-opencode (npm package
`oh-my-openagent`) agent config optimal, given the models and providers they actually have access
to.

## Fixed configuration

Do not guess these. They are constants of this repo.

| Item | Value |
| --- | --- |
| Config dir | `modules/ai-tools/skills` (this skill) |
| Framework config | `modules/ai-tools/oh-my-openagent-framework.json` |
| ThinkPad config | `modules/ai-tools/oh-my-openagent-thinkpad.json` |
| Wiring (framework) | `hosts/framework.nix` -> `xdg.configFile."opencode/oh-my-openagent.json"` |
| Wiring (thinkpad) | `hosts/thinkpad.nix` -> same target |
| Apply command | `home-manager switch` (via repo `Makefile`) |

The user primarily runs on **framework**. Confirm which host they mean before editing; do not touch
a host config they did not ask about.

## Steps

Follow these in order. Do not skip the approval gate.

1. **Confirm the target host.** Ask which machine's config to optimize if not stated. Default focus
   is framework. Read the matching `oh-my-openagent-<host>.json` file to get the current
   assignments.

2. **List the live models.** Run `opencode models` to get the authoritative list of model IDs the
   user can actually select. This is the source of truth — never propose a model ID that is not in
   this list.

3. **List authenticated providers.** Run `opencode auth list` (redact any long tokens in output).
   A config is only valid if its model IDs come from an authenticated, present provider. A model
   from an unauthenticated provider (e.g. `opencode-go/*` when no such provider is logged in) is a
   BROKEN assignment — flag it, do not silently keep it.

4. **Recover the upstream agent roles.** The optimal model depends on each agent's job. Either
   recall the role table below, or delegate a `librarian` lookup of the repo `code-yeongyu/oh-my-opencode`
   (check `agent-model-requirements.ts`, the schema, or README) to confirm current roles and default
   fallback chains. Match each agent to its tier.

5. **Cross-check every current model ID** against the `opencode models` list. Mark each as OK,
   STALE (a newer generation exists), or MISS (not in the list / broken provider).

6. **Propose the optimal assignment per agent**, mapped to the tiers below, using only models the
   user has access to. Present it as a table: agent, current, proposed, reason.

7. **Consult the user before writing.** Use the `question` tool for the judgment calls (see
   "Decision points"). Do not edit any file until the user approves the plan.

8. **Write the config.** Update the correct `oh-my-openagent-<host>.json`. Keep the `$schema` line.
   Keep or refresh the `_comment` so it documents the tier rationale. **Omit skill entries**
   (`frontend-ui-ux-engineer`, `document-writer`) — they are slash-command skills, not agents, so a
   model slot for them does nothing.

9. **Validate.** After writing, re-check that (a) every model ID you wrote exists in `opencode
   models`, and (b) the file is valid JSON (`python3 -m json.tool <file> >/dev/null`). Report any
   MISS as a hard failure and fix it.

10. **Report** the final table and remind the user to run `home-manager switch` to apply. Note any
    other host config that is broken but that you were told not to change.

## Agent roles and tiers

Match each agent to a tier, then pick the best available model in that tier. Roles are from
upstream `oh-my-opencode`. `frontend-ui-ux-engineer` and `document-writer` are SKILLS, not agents —
they have no model slot; never add them.

| Agent | Role | Tier |
| --- | --- | --- |
| `sisyphus` | Primary session orchestrator; plans, delegates, drives to completion | HEAVY (best orchestration model) |
| `prometheus` | Work-plan writer (high-effort structured planning) | HEAVY (planning model) |
| `metis` | Pre-planning analyst; intent classification, hidden-requirement discovery | HEAVY (planning model) |
| `oracle` | On-demand deep advisor; hard debugging, architecture, tradeoffs | HEAVY (max-reasoning; rarely called, so cost is OK) |
| `hephaestus` | GPT-only autonomous deep worker | HEAVY (best GPT deep-worker) |
| `momus` | Work-plan reviewer; single-shot [OKAY]/[REJECT] pass | HEAVY-ish (strong reasoner, review pass) |
| `atlas` | Todo-list orchestrator; executes a pre-written plan | MEDIUM (capable worker, not top-tier) |
| `sisyphus-junior` | Focused single-task executor; no delegation | MEDIUM (capable worker) |
| `explore` | Fast parallel codebase search; read-only | CHEAP (fast/low-reasoning; speed > depth) |
| `librarian` | Fast parallel external-docs / OSS search; read-only | CHEAP (fast/low-reasoning) |
| `multimodal-looker` | Single-shot media (PDF/image) extraction | CHEAP-MEDIUM (no long reasoning chain) |

Tier mapping principles:

- HEAVY -> the newest top model of the preferred provider (e.g. Anthropic `claude-opus-*` for
  orchestration; `claude-fable-*` for planning per upstream default; OpenAI `gpt-*-pro` / newest
  reasoner for oracle/momus).
- MEDIUM -> the newest mid model (e.g. Anthropic `claude-sonnet-*`).
- CHEAP -> the newest fast/cheap model (e.g. OpenAI `gpt-*-luna-fast`, or Anthropic
  `claude-haiku-*`). Do NOT put a heavy model on `explore`/`librarian`; they fire in parallel and
  do not need deep reasoning — a fast model is faster and much cheaper with no quality loss.
- Always prefer the NEWEST id in a family (e.g. `opus-5` over `opus-4-8`, `sonnet-5` over
  `sonnet-4-6`). Providers ship new ids often, so re-derive from the live list every run rather
  than trusting these examples.

## Decision points

Ask the user with the `question` tool before writing. Typical choices:

- **Aggressiveness:** full role-based optimization vs. conservative version-bump-only.
- **explore/librarian tier:** cheapest OpenAI fast model vs. stay all-Anthropic (`haiku`) vs. keep a
  heavier model.
- **Planning agents (`prometheus`/`metis`):** upstream `fable` planning model vs. same top Opus as
  `sisyphus`.
- **`oracle`:** keep the pricey `*-pro` model (max depth, rare calls) vs. downgrade to the standard
  xhigh reasoner.

Make the recommended option the first choice and label it "(Recommended)".

## Guardrails

- Never propose a model ID that is not in the live `opencode models` output.
- Never keep a model from an unauthenticated provider — flag it as broken.
- Never edit a host config the user did not ask for; report it as broken if it is, and stop there.
- Never add `frontend-ui-ux-engineer` or `document-writer` — they are skills, not agents.
- Never write the file before the user approves the proposed table.
- Always validate JSON and re-check every written model ID against the live list before reporting
  done.
- Keep the `$schema` key and a `_comment` that explains the tier rationale so the next run has
  context.
