# Implementation Sequence

The sequence is designed to get a cheap answer from the monolithic baseline **before** building the entire structured investigator.

## Phase 0 — project scaffold and source preflight

- create standalone Mix app;
- add the two requested path dependencies;
- verify `:system_one_sdk` and `:inference` resolve;
- record local versions/commit IDs if available;
- create run-artifact convention;
- start the literature/novelty table in parallel.

**Exit:** project compiles with no experiment logic.

## Phase 1 — strategic-network simulator first

Implement only the simulator/domain types required to create hidden worlds, render observations, expose actions, mask access, emit hidden evaluation targets, and replay seeds.

Implement smoke/small/medium/large profiles and the three case classes.

No structured investigator yet.

**Exit:** same-seed determinism, hidden-truth separation, case-class, and access-mask tests pass.

## Phase 2 — early monolithic baseline reconnaissance

Implement the Inference client plumbing and both monolithic baselines B0a/B0b.

Run them on smoke, then a small baseline-only scale sweep. If they remain near ceiling, increase to medium/large baseline-only cases before building the structured core.

Produce the first actual result artifact now.

**Early stop:** if compute-matched monolithic performance is near ceiling at the largest feasible intended scale on final conclusion quality, true-world coverage, disconfirmation recovery, and resolution balance, pause the research architecture. Do not build five more phases merely to prove bookkeeping works.

## Phase 3 — pure deterministic investigation core

Implement actor, observation, provenance, world registry, investigation state, hard constraints, redundancy dominance, ordinal aggregator, and acquisition bookkeeping.

No live local evaluator calls required.

**Exit:** hand-computed/adversarial unit fixtures pass, including sprawling-world dominance.

## Phase 4 — oracle loop

Implement oracle local evaluator, generation oracle, complete structured investigation loop, artifacts, and replay.

**Exit:** full-oracle smoke cases behave as designed; duplicate provenance, resolvable/non-identifiable, transition, and recovery fixtures pass.

## Phase 5 — Inference generator and attacker

Implement structured candidate generation and attack/reframing through `Inference` with strict JSON Schema output.

**Exit:** candidate records validate, deduplicate, maintain lineage, and generation-bottleneck fixtures run.

## Phase 6 — evaluator adapters and batching contract

Implement the common evaluator behaviour plus all four arms:

- oracle;
- frontier Inference evaluator;
- cheap-general Inference evaluator;
- System One/Jev evaluator.

Implement bounded judgment-state construction and optional transport batching. Run batch-vs-individual agreement fixtures.

At this stage, cheap and System One arms need only pass common-contract tests and minimal live smoke checks when credentials are available. Do not tune them or run Gate 2 yet.

**Exit:** common evaluator suite passes; structured frontier investigator runs end-to-end on smoke cases.

## Phase 7 — cost projection and Gate 1 runner

Before qualification:

- run oracle/fake medium profile to count logical judgments;
- estimate prompt sizes;
- run one live smoke seed for measured usage;
- freeze batching, resource budget, scale, seeds, replicate count, prompts, and practical win thresholds.

Then run B0a, B0b, and B1 over the paired qualification set with repeated model replicates.

**Decision point:** if Gate 1 does not satisfy the predeclared practical win rule, stop before evaluator optimization.

## Phase 8 — Gate 2

Replay frozen local-judgment workloads through oracle/frontier/cheap/System One arms, then optionally run evaluator substitution end-to-end and the fixed-resource breadth experiment. Only now perform evaluator-specific tuning/calibration studies.

## Phase 9 — access curve

Only after initial gates, rerun selected worlds across public/limited/operator/oracle access regimes.

## Explicitly deferred

External environments, real case ingestion, UI, databases, distributed execution, publication-scale statistics, and adaptive evaluator routing.
