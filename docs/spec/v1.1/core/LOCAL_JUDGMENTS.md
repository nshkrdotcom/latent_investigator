# Local Judgment System

Local judgments are bounded semantic questions that cannot be answered reliably by deterministic rules alone.

## Initial judgment classes

| Kind | Example | Primary shape |
|---|---|---|
| `semantic_entailment` | Does message M actually imply claim C? | binary / Noul-like |
| `source_dependence` | Do reports A and B likely derive from the same underlying source? | categorical or ordinal |
| `actor_behavior_plausibility` | Given stated goal/knowledge, how plausible is action A? | ordinal |
| `observation_compatibility` | How compatible is evidence unit E with world W? | ordinal |
| `mechanism_plausibility` | Could this mechanism generate the stated event under constraints? | ordinal |
| `textual_contradiction` | Does statement E contradict claim C? | binary / ordinal |

## Not model judgments

Use deterministic code when facts are explicit:

- actor access before a timestamp;
- chronology;
- known provenance roots;
- hard capability constraints;
- evidence-action availability;
- duplicate structured worlds;
- redundancy dominance between prediction-equivalent worlds.

## Bounded-state requirement

Every model-backed local judgment receives the smallest material slice that can answer the question:

- referenced evidence/provenance unit;
- relevant world assumptions;
- relevant actor knowledge/goals;
- necessary temporal facts;
- frozen rubric.

Do not serialize the entire investigation by default. Record serialized state size and fail explicitly when a provider cannot accept the material state.

## Common ordinal compatibility scale

Only `observation_compatibility` contributes directly to the v1.1 world-fit score:

| Value | Weight |
|---|---:|
| `strongly_against` | -2 |
| `against` | -1 |
| `neutral` | 0 |
| `supports` | +1 |
| `strongly_supports` | +2 |

This is a ranking heuristic, **not** a log-likelihood ratio.

Other classes are operational/diagnostic rather than additional additive evidence terms.

System One may return distributions/confidence and Inference-backed evaluators may return optional self-reported confidence. Store them for analysis; do not let them alter the initial ordinal weight.

## Evaluator arms

1. `oracle`
2. `frontier`
3. `cheap_general`
4. `system_one`

All arms receive the same normalized logical request and return the same project-local `Judgment` contract.

## Logical judgments versus transport calls

One logical judgment does not have to equal one provider call.

The evaluator interface may batch several bounded requests for transport efficiency, but it must return one immutable Judgment per request ID. Qualification runs freeze batching policy and record batch metadata.

## Agreement analysis

Report agreement by judgment class, not one global number. Gate 2 first measures each evaluator without adaptive routing.
