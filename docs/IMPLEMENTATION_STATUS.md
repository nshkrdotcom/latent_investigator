# Implementation Status

Status: **OFFLINE_IMPLEMENTED / RUNTIME_QC_REQUIRED**

The source tree, deterministic simulator, provider adapters, experiment runners, tests, documentation, and handoff are written. No Elixir/Erlang executable is present in the authoring environment.

## Acceptance coverage

### Foundation

- F01 source configuration written; dependency resolution **NOT_RUN**.
- F02 deterministic smoke path implemented and tested in ExUnit source; ExUnit **NOT_RUN**.
- F03 request builders exclude hidden truth/expected labels.
- F04 same-seed simulator determinism test written.
- F05 all three case classes implemented with distinct resolution behavior.
- F06 normalized artifacts, evaluation artifact, SHA verification, and replay test written.

### Baselines

B0a/B0b, scale reconnaissance, separate simulator seed/model replicate fields, and usage recording are implemented.

### Core

Hard source/mechanism/chronology constraints, provenance grouping, uncertain-dependence cap, ordinal fixtures, ambiguity preservation, later evidence, pair-separation acquisition, redundancy dominance, and non-penalized predictive complexity are implemented with tests.

### Generation

Strict-schema Inference generation/attack/repair, structural dedup, parent lineage, oracle generation diagnostic, and true-world retention diagnostics are implemented. Live generation validation is **NOT_RUN**.

### Evaluators

Oracle, Inference, and System One adapters implement the common boundary. Frontier and cheap-general use the same Inference adapter with different clients. Bounded state and optional same-evidence batching are implemented; a batch identity test is written. Live provider agreement/calibration is **NOT_RUN**.

### Gate 1

Paired B0a/B0b/B1 runner, compute target/mismatch recording, scale/case/seed/replicate matrix, P1/P2/P3 summary, resolution guardrail, and pre-run call projection are implemented. Gate 1 execution is **NOT_RUN**.

### Gate 2

Frozen candidate generation, four evaluator arms, resource reporting, and oracle agreement are implemented. Gate 2 execution is **NOT_RUN**.
