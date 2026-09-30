# Conditional Post-Pilot Confirmatory Plan

This document exists so the initial implementation is not mistaken for the whole possible research program. It is **conditional** on Gate 1 producing a real signal and Gate 2 clarifying evaluator behavior.

## Trigger to continue

Proceed beyond the pilot only if all are true:

1. the structured investigator shows a repeatable persistent-state advantage over the strong monolithic baseline;
2. the effect is not an artifact of hidden-information leakage or a weak baseline;
3. generation recall is high enough, or generation failure is itself a clearly characterized research target;
4. evaluator quality/cost is good enough for feasible repeated runs;
5. the simulator does not appear trivially solvable from templates.

## Before confirmatory data collection

Freeze:

- simulator generator version and held-out template set;
- candidate-generation prompt/schema;
- local-evaluator prompt/rubrics;
- aggregation rule;
- search/pruning policy;
- baseline prompt;
- primary outcome(s);
- exclusion/failure rules;
- statistical analysis plan;
- provider/model identities where pinning is possible.

Use pilot variance and template/seed structure to determine sample size. Do not inherit a round number from earlier speculative docsets.

## Likely confirmatory question

A plausible first paper, if warranted, is not “we invented causal investigation.” It is closer to:

> Does persistent explicit representation of competing worlds, provenance, and actor knowledge reduce specific long-horizon investigation failures relative to monolithic language-model reasoning in strategic partially observed environments?

Gate 2 can support a secondary systems result about evaluator quality/cost/search breadth.

## Clustering

Worlds generated from a shared simulator template are not independent. Confirmatory analysis must treat template/family as a clustering or hierarchical unit rather than counting every surface variation as an independent scientific case.

## External validation

After the synthetic confirmatory study, add at least one environment not authored in the same ontology. Candidate directions are listed in `future/EXTERNAL_ENVIRONMENTS.md` and `future/REAL_CASES_AND_COLLABORATORS.md`.

## Publication decision

Do not decide the paper's novelty claim until the literature diligence in `research/LITERATURE_DILIGENCE.md` is complete against the implemented task and observed result.
