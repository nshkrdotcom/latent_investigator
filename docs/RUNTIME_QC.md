# Local Runtime QC — 2026-09-29 (Pacific/Honolulu)

Status: **LOCAL_RUNTIME_QC_PASSED / LIVE_CHECKS_NOT_RUN**

Execution took place in `/home/home/p/g/n/latent_investigator`. The v1.1 research contract was not revised. No execution-derived conceptual contradiction was found.

## Toolchain and dependencies

- `elixir --version`: Elixir 1.20.3, compiled with Erlang/OTP 29; running OTP 29, ERTS 17.0.5.
- `mix --version`: Mix 1.20.3, compiled with Erlang/OTP 29.
- `pwd`: `/home/home/p/g/n/latent_investigator`.
- Initial `sed -n '1,160p' mix.exs` inspection succeeded; `sed -n '1,100p' ../system_one_sdk/mix.exs` failed (missing file); `sed -n '1,100p' ../inference/mix.exs` showed `:inference_workspace`, not the package app.
- Actual package roots were inspected with `cat ../system_one_sdk/packages/system_one_sdk/mix.exs` and `cat ../inference/apps/inference/mix.exs`: apps `:system_one_sdk` 0.6.0 and `:inference` 0.5.0.
- System One checkout: `e757598a89e549274b979f0e77c6a4b2b6667752`; Inference checkout: `3750a03ec62a3c9da11be9caa4dc911ebbbb9801`, obtained with `git -C ../system_one_sdk rev-parse HEAD` and `git -C ../inference rev-parse HEAD`. Both checkouts reported clean via `git ... status --short`.
- With explicit user authorization, dependency paths now point directly to these existing nested package roots. System One's `../system_one_contracts` resolves within its own `packages/` directory. No dependency checkout was edited.
- Existing development `ex_doc` dependency retained. New `mix.lock` records resolved transitive Hex versions/checksums, including Jason 1.4.5, Pristine 0.4.0 and typesafe_api_sdk 0.1.0.
- An initial copied `/tmp/latent-investigator-qc` workspace resolved dependencies, then was abandoned when the user requested direct use of the existing checkouts; no copied-source repairs were used.

## Commands and results

All commands below ran from the project root unless their `git -C` argument specifies otherwise.

| Exact command | Final result |
| --- | --- |
| `mix deps.get` | PASS, exit 0 |
| `mix format` | PASS, exit 0; applied formatting to source/test files |
| `mix format --check-formatted` | PASS, exit 0 |
| `MIX_ENV=test mix compile --warnings-as-errors` | PASS, exit 0 |
| `mix test --warnings-as-errors` | PASS, 29 tests; final seed 745234 |
| `mix test --seed 0 --warnings-as-errors` | PASS, 29 tests |
| `mix latent_investigator.smoke --seed 1 --persist` | PASS, exit 0; final investigation `investigation_6aa760e287888bc3`, round 1 |
| `mix latent_investigator.replay tmp/runs/investigation_6aa760e287888bc3 > tmp/runtime-qc-replay.txt` | PASS, exit 0; replay verifies hashes before loading artifacts |
| `mix ci` | PASS, exit 0; format, compilation, 29 tests; final seed 532391 |
| `git diff --check` | PASS, exit 0 |

The first format check required a second formatter pass for a multiline simulator function clause. Initial compilation failed on a remote call in a guard; subsequent fatal-warning compilation exposed unreachable clauses. Initial ExUnit result was 28/29 (seed 179237), failing on SDK score rubric validation. Repairs and successful reruns are described below. Transitive Hex dependencies emitted warnings during first compilation (Foundation optional TelemetryReporter calls, UUID deprecated Bitwise usage, and Pristine compiler/type warnings); Mix does not make dependency compilation warnings fatal with this project's `--warnings-as-errors`. The application itself passes without suppressing warnings. Imported future file timestamps were automatically reset by Mix.

## Ordinary implementation repairs

- `mix.exs`: use authorized actual relative package paths; replace deprecated `preferred_cli_env` with `cli/0`; explicitly ignore `test/support/` in test discovery (fixtures remain loaded by `test_helper.exs`).
- `target.ex`: evaluate expected actor/role outside guards and pin them in patterns, preserving resolution behavior.
- `provenance.ex`: declare default arguments in a shared function header for `put_edge/5`.
- `generator/inference.ex` and `evaluator/system_one.ex`: mark unused arguments explicitly.
- Baseline/Gate 1/Gate 2 Mix tasks: match the runners' actual success return directly; remove unreachable error-result branches. Runner exceptions/failures still propagate.
- `experiment/gate_1.ex`: remove unreachable empty-list `mean/1` clause; both callers already guard empty lists.
- `evaluator/system_one.ex`: supply string-labelled ordered score levels required by the real SDK; map returned labels back onto the fixed finite compatibility atoms; use `ScoreAnswer.probabilities` for the diagnostic distribution rather than attempting `Map.new` on level definitions.
- `report.ex`, Inference generator/evaluator: preserve the configured model lane separately from the provider identity and count frontier calls using that lane. Executed oracle smoke originally mislabeled 79 logical calls as frontier calls; repaired smoke reports 0. Logical local/generation counts remain separate.
- Regression assertions: score probability distribution; zero oracle frontier calls; a two-judgment frontier batch with a mock provider reports one frontier transport call, preserving vendor identity.
- Remaining source/test changes are `mix format` output. Full changed-file inventory follows.

## Smoke and replay evidence

Final run directory: `tmp/runs/investigation_6aa760e287888bc3`.

All six required files exist: `manifest.json`, `report.json`, `state.json`, `events.jsonl`, `evaluation.json`, `hashes.json`. Independent Python SHA-256 verification matched all five entries in `hashes.json`, and asserted `resource_summary.frontier_calls == 0`. Replay loaded the persisted report successfully. Targets: source supported, mechanism unresolved; the same-source alternative mechanism survives as required for the transition case.

## Live availability

Exact configuration inspection command:

```bash
mix run -e 'IO.inspect(Map.new([:frontier_inference_client, :cheap_inference_client, :system_one_client], fn key -> {key, not is_nil(Application.get_env(:latent_investigator, key))} end))'
```

Result: all three `false`. No frontier/cheap provider host or configured injected client is present in this application. No provider SDK was added, and no live calls were attempted.

- Inference live calls and System One live calls: **NOT_RUN**.
- Baseline reconnaissance and live structured B1 smoke: **NOT_RUN**, frontier client unavailable.
- Gate 1 and Gate 2: **NOT_RUN**, live prerequisites unmet.
- Live cost/latency measurements, generation bottleneck, access curve, publication statistics: **NOT_RUN**.

Next live action is configure a host-owned frontier Inference client and run smoke/small baseline reconnaissance before any qualification gate.

## Changed source/test inventory

- `lib/latent_investigator/acquisition.ex`
- `lib/latent_investigator/actor.ex`
- `lib/latent_investigator/aggregator.ex`
- `lib/latent_investigator/artifact_store.ex`
- `lib/latent_investigator/baseline/monolithic.ex`
- `lib/latent_investigator/config.ex`
- `lib/latent_investigator/constraint.ex`
- `lib/latent_investigator/evaluator.ex`
- `lib/latent_investigator/evaluator/inference.ex`
- `lib/latent_investigator/evaluator/judgment_request.ex`
- `lib/latent_investigator/evaluator/oracle.ex`
- `lib/latent_investigator/evaluator/system_one.ex`
- `lib/latent_investigator/experiment/common.ex`
- `lib/latent_investigator/experiment/cost_projection.ex`
- `lib/latent_investigator/experiment/gate_0.ex`
- `lib/latent_investigator/experiment/gate_1.ex`
- `lib/latent_investigator/experiment/gate_2.ex`
- `lib/latent_investigator/experiment/generation_bottleneck.ex`
- `lib/latent_investigator/experiment/metrics.ex`
- `lib/latent_investigator/experiment/smoke.ex`
- `lib/latent_investigator/generator.ex`
- `lib/latent_investigator/generator/inference.ex`
- `lib/latent_investigator/generator/oracle.ex`
- `lib/latent_investigator/id.ex`
- `lib/latent_investigator/investigation.ex`
- `lib/latent_investigator/judgment.ex`
- `lib/latent_investigator/local_judgments.ex`
- `lib/latent_investigator/observation.ex`
- `lib/latent_investigator/prompt.ex`
- `lib/latent_investigator/provenance.ex`
- `lib/latent_investigator/replay.ex`
- `lib/latent_investigator/report.ex`
- `lib/latent_investigator/runner.ex`
- `lib/latent_investigator/schema.ex`
- `lib/latent_investigator/search.ex`
- `lib/latent_investigator/simulator.ex`
- `lib/latent_investigator/simulator/strategic_network.ex`
- `lib/latent_investigator/target.ex`
- `lib/latent_investigator/util.ex`
- `lib/latent_investigator/world.ex`
- `lib/mix/tasks/latent_investigator.baseline.ex`
- `lib/mix/tasks/latent_investigator.gate1.ex`
- `lib/mix/tasks/latent_investigator.gate2.ex`
- `lib/mix/tasks/latent_investigator.replay.ex`
- `lib/mix/tasks/latent_investigator.smoke.ex`
- `mix.exs`
- `test/latent_investigator/acquisition_test.exs`
- `test/latent_investigator/aggregator_test.exs`
- `test/latent_investigator/artifact_replay_test.exs`
- `test/latent_investigator/baseline_monolithic_test.exs`
- `test/latent_investigator/constraint_test.exs`
- `test/latent_investigator/evaluator_inference_test.exs`
- `test/latent_investigator/evaluator_system_one_test.exs`
- `test/latent_investigator/generator_inference_test.exs`
- `test/latent_investigator/runner_smoke_test.exs`
- `test/latent_investigator/simulator_test.exs`
- `test/latent_investigator/world_test.exs`
- `test/support/fixtures.ex`
- `mix.lock` (new dependency lockfile).

## Live preparation continuation — 2026-09-29

Prepared explicit scripts for `jev` and `gpt-6.1-sol` via Codex. See
[LIVE_CHECKS.md](LIVE_CHECKS.md) for frozen smoke knobs and commands.

Commands and results:

- `mix format scripts/*.exs`: exit 0.
- Initial `mix run scripts/live_preflight.exs`: exit 1, missing required ASM
  `:provider` in validation options; repaired by supplying `provider: :codex`.
  First dev compilation emitted dependency warnings (including toml, websockex,
  and pristine); dependency sources were not altered.
- `mix run scripts/live_preflight.exs` after repair: exit 0; local client
  construction, options, capability declarations, Codex login, and TypeSafe
  credential presence pass; no model calls.
- `mix ci`: exit 0; 29 tests pass, seed 518441.
- Live baseline, structured B1, System One connection check, Gate 1, Gate 2:
  **NOT_RUN**, per user's instruction to pause before live execution.
- `mix run -e 'source = File.read!("scripts/live_check.exs"); ast = Code.string_to_quoted!(source); Code.eval_quoted(quote do: fn -> unquote(ast) end); IO.puts("Live script compiled without execution")'`: exit 0; compiled without invoking the function or sending requests.
- `mix format --check-formatted scripts/*.exs`: exit 0.
- `git diff --check`: exit 0.
