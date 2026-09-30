# Latent Investigator — Local Runtime QC Handoff

## Status

**LOCAL_RUNTIME_QC_PASSED / LIVE_CHECKS_NOT_RUN**

Receiving-agent runtime QC completed on 2026-09-29. See [the runtime QC report](docs/RUNTIME_QC.md) for toolchain, dependency paths, repairs, exact commands, tests, smoke/replay, and live availability. The remaining original handoff below preserves authoring context.

The complete standalone Elixir application, tests, simulator, experiment runners, artifact/replay layer, documentation, and frozen v1.1 specification are written.

The authoring environment contains no `elixir`, `mix`, or `erl` executable. Nothing in this handoff claims successful Elixir compilation or runtime certification.

Your job is to **compile, test, repair implementation defects against the existing v1.1 contract, run the deterministic smoke/replay path, and only then begin live-model checks**. Do not redesign the experiment merely because you prefer a different abstraction. Record an execution-derived contradiction before changing the research contract.

## Authoritative inputs used

1. `system_one_sdk(20260929-233442).xml`
   - SHA-256: `acf283c1d254293cf1fe634f037c0f861bab298f3d524b4db9c5d37bd639fd2d`
   - inspected package version: System One SDK `0.6.0`
2. `inference(20260929-233452).xml`
   - SHA-256: `a7e30d9b4dccc106923367725d4d9dd4ad01a57105b4684e1becd03e6cc84ee9`
   - inspected package version: Inference `0.5.0`
3. Latent Investigator v1.1 docset
   - SHA-256: `b61e766cd467a49357addd023f348e06825937fcd0a229312ef2eaead296c883`
   - preserved under `docs/spec/v1.1/`

## Dependency contract

`mix.exs` intentionally contains only:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

### Important path-layout caveat

The sealed source snapshots are repository/Repomix representations and show package code below nested paths (`packages/system_one_sdk/...` and `apps/inference/...`). The user explicitly requested the simple sibling paths above for this application.

Before changing `mix.exs`, first arrange the local workspace so these two relative paths resolve to **actual Mix package roots** whose `mix.exs` declares `:system_one_sdk` and `:inference` respectively. If the user's real checkout layout differs, prefer filesystem/package-root arrangement consistent with the requested contract. Do not silently convert the project to unrelated Hex/git dependencies.

Also verify System One's own local/path dependencies resolve from that chosen package layout.

Expected logical layout:

```text
<workspace>/
  system_one_sdk/       # package root for :system_one_sdk
  inference/            # package root for :inference
  latent_investigator/  # this repository
```

## Source APIs this implementation intentionally uses

### System One SDK

Verified in the sealed snapshot before coding:

- `SystemOneSDK.new_client/1`
- `SystemOneSDK.evaluate/4`
- `SystemOneSDK.noul/2`
- `SystemOneSDK.choice/3`
- `SystemOneSDK.score/3`
- `SystemOneSDK.Client`
- `SystemOneSDK.NoulAnswer`
- `SystemOneSDK.ChoiceAnswer`
- `SystemOneSDK.ScoreAnswer`
- `SystemOneSDK.Test.client/1`, `stub/3`, `verify!/1`, `close/1`

The System One evaluator uses real typed semantic primitives. It does **not** treat System One confidence as a global causal probability.

### Inference

Verified in the sealed snapshot before coding:

- `Inference.Client.new!/1`
- `Inference.complete/3`
- `Inference.Response`
- strict `{:json_schema, %{name:, schema:, strict:}}` response format
- `Inference.Adapters.Mock`

Live provider SDK ownership remains outside this core app. The application accepts injected `Inference.Client` values for frontier and cheap-general lanes.

## Implementation map

### Deterministic core

- `LatentInvestigator.Investigation`
- `Actor`, `Observation`, `World`, `Judgment`, `EvidenceAction`
- `Provenance`
- `Constraint`
- `Aggregator`
- `Search`
- `Acquisition`
- `Target`
- `Report`
- `ArtifactStore`
- `Replay`

Key implemented semantics:

- immutable judgment IDs/results;
- world ID collision protection;
- append-oriented event history;
- authenticated-source hard constraints;
- authenticated-mechanism hard constraints;
- actor/reference/capability constraints;
- chronology constraint for knowledge acquired after an attributed event;
- known duplicate provenance collapse;
- explicitly uncertain provenance grouping with 0.5 contribution cap;
- five-level ordinal compatibility aggregation;
- no multiplication of evaluator confidence into global likelihoods;
- redundancy dominance for unsupported assumption-heavy worlds;
- no generic complexity penalty when extra structure makes material predictions;
- diversity-preserving pruning;
- simulator-relative pair-separation acquisition.

### Simulator

`LatentInvestigator.Simulator.StrategicNetwork`

Profiles:

- smoke: 5 actors / ~20 observations
- small: 20 / ~150
- medium: 40 / ~400
- large: 80 / ~1000

Case classes:

- `:resolvable` — public authenticated source + public authenticated mechanism witness;
- `:transition` — initially misleading/partial; source can become identified while a same-source/different-mechanism world remains alive unless mechanism evidence is obtained;
- `:non_identifiable` — protective vs hostile-motive worlds remain observationally compatible at public access.

The simulator also contains copied evidence, hidden/known provenance differences, spoofable source claims, heterogeneous actors, access-controlled evidence actions, hidden evaluation targets, and deterministic hidden truth.

### Generative plane

- `Generator.Inference` — strict-schema initial generation, attack, and repair through Inference.
- `Generator.Oracle` — hidden-truth fixture/oracle arm.
- attack lineage is preserved through parent IDs.
- candidate client-ID collisions cannot overwrite prior worlds.

### Local evaluator plane

- `Evaluator.Oracle`
- `Evaluator.Inference` — used for frontier or cheap-general clients
- `Evaluator.SystemOne`

Inference local judgments support optional same-evidence batching while preserving logical request IDs and separate transport-call accounting.

### Experiment runners

- `Experiment.Gate0` — early monolithic scale reconnaissance
- `Experiment.Gate1` — B0a/B0b/B1 paired qualification
- `Experiment.Gate2` — frozen-candidate local-evaluator comparison
- `Experiment.CostProjection`
- `Experiment.GenerationBottleneck` — executable generated-only vs hidden-truth-injected candidate ablation
- `Experiment.AccessCurve`
- `Experiment.Smoke`

Gate 1 currently:

1. runs B1 first;
2. measures actual reported B1 frontier input+output tokens;
3. uses that as B0b iterative compute target;
4. records mismatch rather than claiming perfect match, and marks matching unavailable if the provider reports no token usage;
5. aggregates P1 final target macro-F1 globally;
6. records P2 true-world retention;
7. records P3 transition recovery / recovery round;
8. guards with resolution balanced accuracy;
9. leaves final continuation subject to manual leakage/budget/baseline trace review.

## Runtime model configuration

### Frontier/cheap Inference

Inject configured clients:

```elixir
Application.put_env(:latent_investigator, :frontier_inference_client, frontier_client)
Application.put_env(:latent_investigator, :cheap_inference_client, cheap_client)
```

Do not add a provider SDK to this core repository merely to make a smoke test convenient unless the user explicitly wants that dependency. Use the user's host/provider environment.

### System One

Optionally inject:

```elixir
Application.put_env(:latent_investigator, :system_one_client, system_one_client)
```

Otherwise `LatentInvestigator.Config.system_one_client!/0` uses `SystemOneSDK.new_client/0` and the SDK's configured/default provider.

## Mandatory local QC sequence

Run from the Latent Investigator project root.

### 1. Prove toolchain and dependency roots

```bash
elixir --version
mix --version
pwd
sed -n '1,160p' mix.exs
sed -n '1,100p' ../system_one_sdk/mix.exs
sed -n '1,100p' ../inference/mix.exs
```

Confirm the dependency package apps are the expected names before proceeding.

### 2. Resolve and format

```bash
mix deps.get
mix format
mix format --check-formatted
```

If dependency resolution fails because the user's real repository layout differs from the requested sibling package-root layout, fix the workspace/package-root arrangement first. Document any necessary deviation.

### 3. Compile with warnings fatal

```bash
MIX_ENV=test mix compile --warnings-as-errors
```

Repair all compile errors/warnings against the actual APIs. Pay particular attention to:

- struct field/API drift in System One answer/response types;
- Inference response-format/client option drift;
- Elixir-version formatting/compiler warnings;
- direct `Jason` availability through the supplied dependency graph.

Do not paper over provider/API errors with neutral/default judgments.

### 4. Run tests

```bash
mix test --warnings-as-errors
mix test --seed 0 --warnings-as-errors
```

Tests intentionally cover:

- simulator determinism/access masking/case classes;
- hard source/mechanism/chronology constraints;
- duplicate and uncertain provenance;
- hand-computed aggregation;
- redundancy dominance;
- acquisition;
- System One semantic adapter with `SystemOneSDK.Test`;
- Inference adapter with `Inference.Adapters.Mock`;
- Inference batch identity;
- strict generation parsing;
- monolithic baseline normalization;
- pure oracle investigation loop;
- artifact hash verification/replay.

### 5. Deterministic zero-network smoke

```bash
mix latent_investigator.smoke --seed 1 --persist
```

Then replay the emitted run directory:

```bash
mix latent_investigator.replay <RUN_DIR>
```

Verify that the run contains:

- `manifest.json`
- `report.json`
- `state.json`
- `events.jsonl`
- `evaluation.json`
- `hashes.json`

No model credentials should be required for this step.

### 6. Full source CI alias

```bash
mix ci
```

Only after all preceding checks are green should the implementation be considered runtime-ready.

## Live experimental order

Do **not** start with Gate 1.

### A. Configure one frontier Inference client

Use the user's existing provider host/dependencies and inject the client.

### B. Baseline reconnaissance first

```bash
mix latent_investigator.baseline
```

Start on smoke/small, then medium/large only as warranted. This is the cheapest kill test from v1.1: if a compute-rich monolithic model is already near ceiling at intended scale, inspect that result before spending time/money validating the structured architecture.

### C. One live structured smoke

Run a small/smoke B1 programmatically with the configured frontier client. Inspect raw artifacts, local-judgment batching, generation coverage, and token counts.

### D. Freeze Gate 1 run knobs

Before qualification, record:

- provider/model IDs;
- prompts/schema version (`1` in current manifest);
- batching size;
- `k_initial`;
- round budget;
- max alive worlds;
- profiles;
- seed list;
- replicate count;
- practical thresholds;
- measured provider pricing/cost basis if cost is used.

`Experiment.CostProjection.project/1` gives call-volume estimates but deliberately does not invent prices.

### E. Gate 1

```bash
mix latent_investigator.gate1
```

Default code uses medium profile, all three case classes, 10 seeds, and 3 replicates. This can be expensive. Do a one-seed/one-replicate programmatic dry run first.

Do not claim Gate 1 passes merely because `automatic_continuation_precheck` is true. Inspect:

- B0b compute-match ratios;
- any baseline/provider failures;
- hidden-truth leakage;
- candidate generation failures;
- transition traces;
- false resolution/non-resolution behavior;
- provider usage/cost.

### F. Gate 2 only if Gate 1 justifies it

Configure:

- frontier Inference client;
- cheap-general Inference client;
- System One client.

Then:

```bash
mix latent_investigator.gate2
```

Optional candidate-generation bottleneck diagnostic, using the frontier client while holding downstream scoring fixed:

```bash
mix latent_investigator.generation_bottleneck
```

Gate 2 freezes frontier-generated candidates before replaying the local workload through oracle/frontier/cheap/System One arms. It reports resource use and agreement to oracle for exercised judgment classes.

## Known intentional limitations / do not “fix” casually

1. **Ordinal aggregation is not Bayesian.** That is deliberate. Local evaluator confidence is diagnostic only.
2. **Acquisition is simulator-relative pair separation**, not a real-world EIG claim.
3. **Candidate generation is frontier-model dependent** and may be the dominant bottleneck.
4. **Search breadth benefit is a hypothesis**, not an architectural premise.
5. **The simulator is synthetic and benchmark-closed.** Initial publication/tool claims must remain scoped accordingly.
6. **No UI/database/distributed runner/external environment is included.** Those were explicitly deferred.
7. **Live provider SDKs are host-owned.** The core app declares only System One SDK and Inference as requested.
8. **System One bounded-state limits matter.** Do not send whole-investigation state when a bounded world/evidence unit suffices.

## Source-only QC completed here

The authoring environment performed non-Elixir checks only:

- exact two requested dependency declarations present;
- no zero-byte files;
- JSON example files parse;
- no TODO/FIXME/PLACEHOLDER markers in implementation/test code;
- local Markdown links checked after handoff/source-QC creation;
- parentheses/brackets/braces balanced under a string/comment-aware static scan;
- no `hidden_truth` token in model prompt builder;
- monolithic model payload no longer includes hidden `case_class` metadata;
- sealed source APIs above were inspected before calls were written.

These checks are **not** substitutes for compilation or ExUnit.

## Checks explicitly NOT_RUN in the authoring environment

- `mix deps.get`
- `mix format`
- Elixir compilation
- warnings-as-errors
- ExUnit
- deterministic smoke command
- replay command under BEAM
- any System One live call
- any Inference live call
- baseline reconnaissance
- Gate 1
- Gate 2
- empirical cost/latency measurement
- generation-bottleneck experiment
- access-curve experiment
- publication-scale statistics

## Completion criteria for the receiving agent

Return/record:

1. exact toolchain versions;
2. dependency paths/commits or SHAs actually used;
3. all source changes made during repair;
4. `mix format --check-formatted` result;
5. warnings-as-errors compile result;
6. ExUnit result/count;
7. deterministic smoke result;
8. replay/hash result;
9. live checks actually run, with unavailable ones explicitly `NOT_RUN`;
10. any execution-derived conceptual contradiction separately from ordinary implementation bugs.

Do **not** start a v1.2 research-design revision as part of ordinary runtime QC.
