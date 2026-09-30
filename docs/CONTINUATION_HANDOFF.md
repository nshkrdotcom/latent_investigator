# Continuation handoff — 2026-09-29

## Stopping point

**LOCAL_RUNTIME_QC_PASSED / LIVE_BASELINE_AND_SYSTEM_ONE_PASSED / STRUCTURED_INTERRUPTED**

The user requested an immediate documented stopping point, then commit and push.
The active structured smoke was terminated at 15:24:45 Pacific/Honolulu
(2026-09-30 01:24:45 UTC). No live-check BEAM process or child `codex exec`
process remains. Do not interpret its orderly SIGTERM exit code 0 as a passing
structured experiment. No structured live result or persisted run was emitted.
Existing `tmp/runs` directories are prior deterministic oracle smokes.

Read this first, then HANDOFF.md, IMPLEMENTATION_STATUS.md, and
spec/v1.1/AGENT_START_HERE.md. The frozen v1.1 contract remains unchanged.
The original handoff's dependency and environment descriptions are historical;
this document and current code describe the receiving environment.

## User decisions and permissions

- Work efficiently in the existing checkout; no copied QC workspace/worktree.
- Relative/Git dependency paths were authorized, superseding original sibling-root
  path requirements. The user then explicitly requested latest Hex Inference.
- Use Jev for System One and `gpt-6.1-sol` through Codex for Inference.
- The preparation pause was lifted: the user authorized live execution.
- The latest instruction stops current execution and asks for handoff/commit/push.
  Run no further live requests in this stopping turn. When asked to continue,
  resume the remaining structured smoke, rather than repeating passed live checks.
- Gate 1/2 and larger experiments have not been run or qualified. Do not expand
  the experiment design or claim architecture advantage from these smoke checks.

## Repository and dependency state

Project: `/home/home/p/g/n/latent_investigator`, branch `main`.
Remote `origin`: `n:nshkrdotcom/latent_investigator.git` (existing SSH alias).

Earlier commits:

- `c648d1a`: local QC repairs, Hex Inference and bridge dependencies, mix.lock.
- `ec4444a`: prepared preflight and live scripts.

Current mix.exs declares:

- System One path `../system_one_sdk/packages/system_one_sdk`.
- Inference `~> 0.5.1` (resolved 0.5.1).
- Agent Session Manager `~> 0.17.3`, Codex SDK `~> 0.21.3` in dev/test.

Do not revert these to the authoring handoff's original dependency layout.
Toolchain: Elixir/Mix 1.20.3 and OTP 29.0.5. Credentials stay in environment:
`TYPESAFE_API_KEY` is present; Codex is logged in through ChatGPT. No credentials
are committed. `TYPESAFE_BASE_URL` optionally overrides the TypeSafe endpoint.
No cheap-general client is configured.

## What passed

Local QC previously passed format, fatal-warning project compilation, 29 tests
(including seed 0), deterministic smoke, hash verification, replay, and CI.
Latest `mix ci` passed all 29 tests with seed 214068 after live config repairs.
Initial dev dependency compilation emitted warnings in upstream packages;
upstream source was not changed.

Live System One connection probe passed with `jev-latest`, resolving to
`jev-1.13.0`, typed noul answer 0.99, 281 input / 20 output tokens.
Sanitized evidence: `qc/2026-09-29/system-one.json`.
This certifies connection and typed response only, not evaluator qualification.

Live baseline passed with Codex `gpt-6.1-sol`, smoke/transition/public, seed 1,
round budget 1. B0a made 2 calls; B0b made 6 (three stages per evidence round).
Both achieved macro-F1 1.0, resolution balanced accuracy 1.0, and true-world
retention; both classified the two targets as supported/unresolved correctly.
Evidence: `qc/2026-09-29/baseline.txt` (verbatim metrics summary).

This is one easy smoke case, not evidence of success at intended medium/large
scale. Both baseline summaries show zero input/output tokens and cost, which
means unavailable reporting through this adapter path, NOT zero actual usage.
Do not use them to claim compute matching or cost superiority. Gate0 currently
returns scored summaries rather than raw responses, so full baseline response
traces were not retained by this script. That is a limitation to address before
qualification, not a reason to rerun this passed smoke without need.

## Live failures repaired

1. Temporary `/tmp` working directory initially failed Codex's trusted Git
   check before inference. Added `skip_git_repo_check: true`.
2. ASM's stream timeout default was 60 seconds despite a 300-second transport
   timeout. Added `stream_timeout_ms: 300_000` to query opts; drop this stream-only
   key when calling provider option validation.
3. Literal model ID `jev` returned HTTP 400 unknown model. Live list_models
   advertised `jev-latest` and `jev-preview`; use stable Jev ID `jev-latest`.

Inference ASM locks completion-only. Observed Codex invocation uses read-only,
ephemeral, ignore-user-config, ignore-rules, disabled skills/web search, and a
schema file. The deterministic core still owns global scoring, provenance,
hard constraints and replay. Normal model arms receive public simulator state,
not hidden truth or expected labels.

## Immediate continuation

1. Read this handoff and inspect `git status --short`. No live processes should
   be running. The stopping commit contains the setup fixes and evidence.
2. Optional local-only availability check:
   `mix run scripts/live_preflight.exs`.
   This constructs clients, validates options and advertised capabilities,
   checks local Codex login and credential presence; it sends no model requests.
3. Resume the interrupted structured smoke with:
   `mix run scripts/live_check.exs structured`.
   This restarts from generation; there is no checkpoint to resume.
4. Inspect `tmp/live_checks/structured-*.txt` and its referenced `tmp/runs` run.
   Check generated candidate coverage, judgment batches, raw judgments,
   model/provider IDs, transport accounting and usage availability. Replay with
   `mix latent_investigator.replay <RUN_DIR>`; verify the six expected artifacts.
5. Record exact commands/results in RUNTIME_QC.md and update this handoff/status.
   If it fails, debug against actual APIs, not by adding neutral judgments.
6. Do not automatically start Gate 1/2 or scale up: first assess the ceiling
   baseline smoke, missing token reporting, and missing baseline raw traces.

Frozen structured knobs in scripts/live_check.exs: smoke, transition, public,
seed 1, four initial worlds, round budget 1, maximum eight alive worlds,
same-evidence evaluator batching of eight, generator and evaluator both frontier
Inference, persisted artifacts, arm b1. Attack/repair retain runner defaults.
Codex reasoning medium; stream/transport timeouts 300 seconds. System One HTTP
timeout 60 seconds. The structured path can need many model requests; a run
may take several minutes. Keep user informed and stop promptly if instructed.

## Artifact and validation notes

Raw local artifacts are under `tmp/live_checks`; System One raw response includes
transport headers/cookies, so only a sanitized summary is committed. The baseline
metrics summary and sanitized System One evidence are committed under docs/qc.
`tmp/runs` is ignored. Do not commit raw credentials/headers or runtime directories.

Exact live commands, errors, request IDs, and test outputs are recorded in
RUNTIME_QC.md. Final stopping checks are recorded there; use Git history and origin/main to verify delivery.
