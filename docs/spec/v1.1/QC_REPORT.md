# QC Report — v1.1

**Static docset status:** PASS

This package contains specification only. No Elixir project, provider call, simulator run, Gate 1 result, or empirical claim has been executed.

## Package checks

Static checks run against the final v1.1 working tree before hashing/zipping:

- package files before final SHA regeneration: 54
- Markdown files: 51
- Markdown words: approximately 17k
- JSON templates parsed: 1
- zero-byte files: 0
- broken local Markdown links: 0
- missing explicit local doc references: 0
- implementation source files (`.ex`, `.exs`): 0
- stale exact v1 run-manifest version references: 0

## Source-contract checks

Verified statically against the supplied sealed snapshots:

### System One SDK

- snapshot SHA-256: `acf283c1d254293cf1fe634f037c0f861bab298f3d524b4db9c5d37bd639fd2d`
- package version: `0.6.0`
- facade exposes `SystemOneSDK.new_client/1`, strict `noul`, `choice`, `score`, `prepare!`, and `evaluate`
- facade exposes bounded batch collection/streaming through `evaluate_many` / `evaluate_stream`, backed by `SystemOneSDK.Batch`
- SDK batch implementation preserves indexed results and configurable bounded concurrency
- v1.1 uses System One only for bounded local judgments; no global-likelihood API is assumed

### Inference

- snapshot SHA-256: `a7e30d9b4dccc106923367725d4d9dd4ad01a57105b4684e1becd03e6cc84ee9`
- package version: `0.5.0`
- facade exposes `Inference.complete/3` and `Inference.capabilities/1`
- response-format contract includes named strict JSON Schema output
- v1.1 does not assume a provider-specific batching API; any grouped local-judgment call is project-level structured completion

## v1.1 critique-response checks

The docset now explicitly includes:

- co-primary Gate 1 outcomes that cannot be passed by deterministic bookkeeping alone;
- compute-matched iterative monolithic B0b baseline;
- small/medium/large scale axis and a rule that small-only negative evidence does not falsify an untested long-scale claim;
- `resolvable`, `non_identifiable`, and `transition` case classes;
- false non-resolution/over-hedging metrics beside false unique-resolution metrics;
- repeated model replicates per simulator seed;
- early monolithic baseline reconnaissance before full structured-core implementation;
- redundancy-dominance/parsimony adversarial fixtures without an arbitrary numeric complexity prior;
- pre-run cost/token/call projection before Gate 1 qualification;
- bounded local-judgment state for Jev/System One and explicit context-limit failure handling;
- optional batching with batch-vs-individual QC;
- simulator-relative claim boundaries for acquisition/prediction;
- literature/novelty diligence beginning in parallel with early implementation.

## Runtime / empirical gates

All remain **NOT_RUN**:

- Mix dependency resolution
- Elixir compile
- formatter / ExUnit
- simulator execution
- B0a/B0b baseline reconnaissance
- oracle-loop execution
- Inference mock/live integration
- frontier-model calls
- cheap-general model calls
- System One/Jev calls
- batch-vs-individual evaluator comparison
- cost projection using rendered/runtime requests
- Gate 1 qualification
- Gate 2 evaluator comparison
- access-curve experiment
- literature search execution/completion
- publication-scale statistics

## Issues

No static packaging/reference/API-assumption issue was found in the checks above.

Runtime behavior remains unknown by design.
