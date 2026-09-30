# Test and QC Plan

## Static/source tests

- dependency applications resolve;
- project compiles with warnings as errors;
- formatter check;
- ExUnit;
- deterministic fixture hashes stable;
- no simulator truth/evaluation targets leak into model payloads.

## Simulator tests

- same seed/profile/case class -> identical hidden world and observation stream;
- different seed -> different world within configured family;
- resolvable cases contain at least one warranted material distinction;
- non-identifiable cases preserve the declared ambiguity under current access;
- transition cases become resolvable only after the intended reveal/action;
- qualification suite covers all required strategic features;
- access regimes are nested and never reveal forbidden fields;
- evidence action execution matches hidden world;
- candidate-world action prediction is deterministic for simulator-compatible worlds;
- hidden evaluation targets never enter baseline/investigator inputs.

## Early baseline tests

- B0a and B0b receive identical visible state;
- B0b never receives structured-core artifacts;
- iterative B0b respects configured call/token budget;
- baseline candidate outputs can be structurally matched to hidden truth;
- repeated model runs preserve seed while varying replicate ID.

## Deterministic core tests

1. chronology contradiction rejects a world;
2. actor capability contradiction rejects a world;
3. duplicate provenance contributes once;
4. uncertain provenance component is capped;
5. aggregation returns expected fit on hand-computed fixtures;
6. soft pruning preserves configured diversity slot;
7. pruned world can be revived without losing lineage;
8. acquisition pair-separation matches hand computation;
9. tie-breaking is deterministic;
10. pure replay reproduces final state hash;
11. sprawling world with unused assumptions is redundancy-dominated by prediction-equivalent simpler world;
12. complex world is not penalized when extra structure changes a material prediction.

## Evaluator contract tests

All evaluator arms must pass a common contract suite over fixture requests.

- valid judgment shape;
- ordinal mapping valid;
- provider metadata preserved where reported;
- missing usage/cost stays nil;
- provider error recorded, not converted to neutral;
- same logical judgment request can be sent to each arm;
- bounded state builder includes only referenced evidence/world slice;
- oversized-state rejection/truncation is explicit, never silent.

## Batching tests

- batch output preserves one logical judgment ID per request;
- batched and individual fixture judgments are compared before qualification;
- batch configuration/chunk size recorded in run manifest;
- batching never changes provenance grouping or denominator bookkeeping.

## Inference integration tests

- JSON Schema capability checked before dispatch;
- structured object parsed and validated;
- malformed object fails closed;
- raw provider response not written to artifact store.

## System One integration tests

- prepared question sets reused where defined;
- each judgment class maps to intended primitive;
- `SystemOneSDK.Response.fetch!/2` result maps to common judgment contract;
- response metadata retained;
- provider confidence/distribution does not bypass ordinal aggregation;
- bounded local states stay within provider limits or fail with recorded reason;
- SDK batch/concurrency use, if enabled, preserves logical judgment identity.

## Experiment tests

- B0a/B0b/B1 receive identical visible evidence per round;
- generation-oracle truth injection unavailable to normal generator;
- local-judgment oracle labels never exposed to non-oracle evaluator;
- run config/model IDs frozen before first qualification call;
- final material-status scorer penalizes both false certainty and blanket unresolved output;
- seed and model replicate are distinct fields;
- compute-matching tolerance is checked after each paired run;
- cost projection artifact exists before qualification sweep.

## Runtime QC status convention

Every implementation handoff reports each gate as `PASS`, `FAIL`, or `NOT_RUN`. Do not infer runtime success from static source review.
