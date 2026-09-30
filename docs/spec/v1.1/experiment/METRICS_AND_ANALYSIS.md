# Metrics and Analysis

The initial experiment needs enough measurement to diagnose behavior without turning measurement into the project.

## Co-primary Gate 1 metrics

### Final material conclusion quality

Each simulator case contains hidden evaluation targets with access-relative expected statuses:

- `supported`
- `rejected`
- `unresolved`

The final report returns the same three-way status for every target it addresses. The harness reports:

- macro-F1 across the three statuses;
- per-status precision/recall;
- confusion matrix.

This is the primary end-to-end final-investigation measure. It penalizes both false certainty and blanket hedging.

### True-world retention

At each round, whether any emitted/alive candidate is compatible with the hidden generating mechanism under the frozen structural matcher. Monolithic baselines must emit explicit candidate explanations so they can be matched by the same evaluator.

### Disconfirmation recovery

For the planted attractive false explanation:

- recovery success after decisive evidence;
- recovery latency in rounds;
- whether a true-compatible candidate remains after recovery.

## Resolution guardrails

### Resolution balanced accuracy

Binary view over cases/targets whose hidden evaluation status is:

- resolvable (`supported` or `rejected`), versus
- unresolved.

Report balanced accuracy so a system that always answers "unresolved" cannot score well.

### False unique resolution

Rate of uniquely asserting a material distinction labeled `unresolved` under the current access regime.

### False non-resolution / over-hedging

Rate of returning `unresolved` for targets the current evidence labels `supported` or `rejected`.

## Mechanism diagnostics

### True-world rank

Rank of the best compatible world by deterministic fit. Undefined if no compatible world exists.

### Alternative-retention correctness

For designed ambiguous pairs, whether both remain represented before discriminating evidence and the incompatible one is eliminated afterward.

### Duplicate-provenance inflation

Change in a world's fit/rank when surface copies of an already-known provenance root are introduced. Deterministic provenance logic should make this approximately zero once dependence is known.

### Acquisition quality — simulator-relative only

- selected action separation score;
- simulator best-action separation score;
- regret = oracle minus selected.

This metric is valid for the controlled simulator because candidate worlds and evidence actions share an executable schema. It is **not** a claim that real-world evidence acquisition can be scored this way.

### Generation recall

Presence/partial presence of hidden mechanism among generated worlds at K and by round.

### Search breadth

- valid unique worlds generated;
- peak alive worlds;
- worlds evaluated;
- worlds pruned/revived.

## Resource metrics

- generator/attacker calls;
- local judgments by class;
- batched versus unbatched judgment counts;
- input/output tokens when reported;
- provider-reported cost when available;
- separately labeled estimated cost where configured;
- wall time;
- p50/p95 local-judgment latency;
- failure/retry counts.

## Replication unit

The simulator seed and model replicate are separate identifiers.

Default qualification design:

- >=10 simulator seeds;
- 3 independent model replicates per arm per seed.

Report:

1. seed-level means across replicates;
2. within-seed stochastic dispersion;
3. paired arm differences on the same seed/replicate index when possible.

Do not pretend 30 stochastic runs over 10 worlds are 30 independent worlds.

## Aggregation metrics are not probabilities

Do not report `fit_score` as confidence or posterior probability.

## Gate 1 practical decision rule

Use the predeclared rule in `GATE_1.md`. The 0.10/0.05 thresholds are continuation thresholds, not publication effect sizes.

## Later confirmatory analysis

If Gate 1 warrants a publication-scale study, use the pilot to estimate seed-level variance and define the statistical analysis plan before collecting confirmatory worlds. Template/family clustering must be handled explicitly if multiple worlds share generator templates.
