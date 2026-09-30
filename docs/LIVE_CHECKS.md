# Prepared live checks

Prepared for System One `jev` and Inference 0.5.1 through ASM/Codex with
`gpt-6.1-sol`. Live requests remain **NOT_RUN** at the user's requested pause.
The Hex dependencies and lockfile were committed in `c648d1a`.

From the project root, run the local preflight:

```bash
mix run scripts/live_preflight.exs
```

It constructs clients, validates ASM options and advertised completion-only/schema
support, checks local Codex login status, and checks that `TYPESAFE_API_KEY` is
present. It sends no model requests. `TYPESAFE_BASE_URL` optionally sets the
TypeSafe endpoint. Keys are never printed. Models are pinned to the requested IDs;
remote acceptance is unverified. No cheap-general lane is configured.

After approval to run live checks, start with:

```bash
mix run scripts/live_check.exs baseline
```

This runs Gate 0 on smoke/transition/public, seed 1, with one iterative round:
one single-shot baseline and an iterative baseline. Inspect results before
proceeding to the structured smoke:

```bash
mix run scripts/live_check.exs structured
```

The B1 smoke uses the same case and seed, four initial candidates, one round,
eight maximum alive worlds, and evaluator batching of eight. Generation and
local evaluation use Codex; hidden truth remains in deterministic evaluation.
Structured artifacts persist under `tmp/runs`; all check summaries persist under
`tmp/live_checks`. Inspect generation coverage, judgments, token reporting, and
replay artifacts before considering larger runs. These checks do not qualify Gate 1.

A separate minimal typed System One connection check is ready:

```bash
mix run scripts/live_check.exs system-one
```

The Codex client explicitly admits the agent-session adapter; Inference locks
completion-only execution. Each request creates a fresh session, with a temporary
working directory and medium reasoning effort, and a 300-second transport timeout.
The bridge permits the exact model ID to pass through even if its local registry
is older. System One uses a 60-second HTTP timeout.

ASM reports token information in its cost structure, while Inference's shared
adapter reads a separate usage field. Actual token accounting must be inspected
on the first live response: do not claim compute matching when token counts are
unavailable. No provider prices or live model availability have been certified.
