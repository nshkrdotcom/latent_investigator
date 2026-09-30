# Implementation Architecture

## Boundary

`LatentInvestigator.Runner` orchestrates a complete investigation. It does not own provider-specific semantics.

### Generative plane

`LatentInvestigator.Generator.Inference` uses the supplied `Inference` dependency for strict-schema candidate-world generation, attack, and repair. `Generator.Oracle` supplies simulator-authored candidates for deterministic ceilings and smoke tests.

Generation is intentionally separate from evaluation because missing the useful world may be the dominant failure mode.

### Local-judgment plane

`LatentInvestigator.Evaluator` is the project-local contract. Implementations are:

- `Evaluator.Oracle` — hidden-truth/fixture ceiling;
- `Evaluator.Inference` — frontier or cheap-general model using the same bounded request format;
- `Evaluator.SystemOne` — System One/Jev semantic questions using real `noul`, `choice`, and `score` primitives.

`Evaluator.Inference.judge_many/2` may batch worlds that share an evidence unit. Logical judgment identity remains per request; transport batching is separately recorded.

### Deterministic plane

Ordinary Elixir code owns:

- investigation registry and append-oriented history;
- observation and actor records;
- provenance graph and evidence units;
- authenticated facts and chronology constraints;
- ordinal aggregation;
- redundant-world dominance;
- pruning/diversity;
- simulator-relative action separation;
- target resolution;
- metrics, artifacts, and replay.

## Aggregation

The initial rule is deliberately non-Bayesian.

1. Hard constraints reject impossible worlds.
2. Known copied/derived observations are one evidence unit.
3. Explicitly uncertain-related evidence is one `:uncertain` unit and its ordinal contribution is capped at 0.5.
4. Each alive world receives one five-level compatibility judgment per evidence unit: `-2..2`.
5. Fit is the sum of effective ordinal weights divided by `2 * evidence_unit_count`.
6. Provider confidence/distributions are persisted but do not change global fit.
7. A world with identical predictions/evidence pattern plus strictly more unsupported assumptions is redundancy-dominated; complexity is not otherwise penalized.

This rule is an experimental starting point, not a claim that the judgments are likelihood ratios.

## Hidden-truth boundary

The simulator owns hidden truth and expected target labels. Normal generator, evaluator, and baseline request builders receive only visible actors, observations, public task targets, available evidence actions, and prior model output where appropriate.

Post-run `evaluation.json` contains hidden evaluator material for offline scoring/replay. It is written only after the run and is never fed back into a model request.
