# Record Contracts and Invariants

This file collects contracts implementers must enforce. It deliberately avoids a separate JSON-schema suite during the first build.

## IDs

All project-local IDs are opaque UTF-8 strings. Never derive semantic meaning by splitting IDs.

## Run identity invariants

A run manifest distinguishes:

- `seed` — deterministic simulator world identity;
- `model_replicate` — stochastic model repetition within the same simulator seed;
- `arm` — B0a/B0b/B1 or later evaluator arm;
- `profile` — smoke/small/medium/large;
- `case_class` — resolvable/non_identifiable/transition;
- access regime;
- frozen prompt/schema/batching/resource hashes.

Never overload model replicate as simulator seed.

## Investigation invariants

- round never decreases;
- observations are append-only;
- world history is append-only even when status changes;
- a rejected world is never silently rewritten into an alive world;
- judgments are immutable once recorded;
- evidence actions record selection rationale and resulting observation IDs;
- simulator hidden truth/evaluation targets are never placed in normal investigator state.

## World invariants

- every referenced actor/observation/source exists;
- `hard_failures` is nonempty when status is `:rejected` for hard constraints;
- `fit_score` is null until aggregation has run;
- parent IDs identify generation lineage;
- unknown/new mechanism descriptions are preserved rather than coerced into an existing family;
- redundancy dominance records the dominating world ID and reason rather than silently deleting structure.

## Judgment invariants

- `kind` belongs to frozen judgment-class set;
- ordinal weight belongs to `[-2,-1,0,1,2]` when applicable;
- provider confidence nullable and bounded when present;
- usage/cost nullable rather than invented;
- one request ID maps to at most one admitted judgment result;
- batch ID/position may be present but does not change logical identity;
- serialized bounded-state size is recorded when practical.

## Provenance invariants

- authenticated source identity cannot be overwritten by a model claim;
- known duplicate/derived observations do not create additional independent evidence units;
- uncertain dependence remains uncertain until evidence resolves it;
- hidden simulator provenance is stored separately from investigator-known provenance.

## Evaluation-target invariants

- hidden target statuses are evaluator-only;
- final report target statuses are scored only after the run completes;
- target IDs may appear in a public task contract only when the proposition itself is intended to be answered; the expected label never appears in model input.

## Artifact invariants

- no credentials;
- no raw provider response persisted by default;
- model/provider identity and prompt/schema version retained;
- every final report traces to a frozen run manifest and ordered event log.
