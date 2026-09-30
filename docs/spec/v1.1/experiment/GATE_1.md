# Gate 1 — Does Explicit Investigation Structure Add Value?

## Question

Does the structured investigator produce better **investigation behavior and final epistemic conclusions** than strong monolithic frontier-model baselines when evidence, model family, and resource budgets are controlled?

A win on deterministic bookkeeping alone is not sufficient.

## Arms

### B0a — strong monolithic baseline

The best serious single-investigator prompt. It receives all currently visible evidence, the action catalog, and its prior round report/transcript, but no external world/provenance graph.

### B0b — compute-matched iterative monolithic baseline

Same state boundary as B0a, but allowed repeated independent analysis / attack / revise calls until it reaches a frontier-model token/call budget comparable to the structured arm for that run. It still has no authoritative external world registry, provenance graph, hard-constraint engine, or deterministic aggregation.

The matching target is total frontier-model input+output tokens within +/-10% when provider accounting permits; otherwise match call budget and report the token mismatch.

### B1 — structured frontier investigator

Frontier general model for generation, attack, and local semantic judgment; deterministic Elixir core for state, provenance, constraints, aggregation, search bookkeeping, and replay.

### Diagnostics

Full-oracle and partial-oracle runs are QC/attribution diagnostics and cannot establish Gate 1 success by themselves.

## Case sequence and scale

### Smoke

Hand-checkable 5-actor / ~20-observation fixtures. Debugging only.

### Baseline reconnaissance

Run B0a and B0b before the full structured core is implemented at increasing simulator scales. The purpose is to discover whether the plain model already handles the intended difficulty and to select the smallest nontrivial Gate 1 scale.

Default profiles:

| Profile | Actors | Observations | Approx. visible text target | Purpose |
|---|---:|---:|---:|---|
| small | ~20 | ~150 | 10k–25k tokens | first realistic case |
| medium | ~40 | ~400 | 30k–70k tokens | default Gate 1 target |
| large | ~80 | ~1000 | 80k–160k tokens | stress / long-investigation claim |

The actual token totals are measured, not assumed.

**Scale-selection rule:** Gate 1 should target `medium` by default. If the pre-run cost projection makes medium infeasible, small may be used but the long-investigation hypothesis is recorded `NOT_TESTED`, not falsified. If B0b is already near-ceiling at medium, run baseline-only large reconnaissance before investing in the full structured loop.

### Qualification

Default: at least 10 simulator seeds at the chosen Gate 1 scale, with 3 independent model replicates per arm per seed. The simulator seed is held fixed across paired arms; model replicate IDs are distinct. Deterministic providers may collapse repeated runs, but the runner still records that fact.

This is still a qualification study, not publication-scale confirmatory evidence.

## Required case-class balance

The qualification seed set must contain all three hidden evaluation classes:

- `resolvable` — the currently visible evidence warrants a material distinction;
- `non_identifiable` — at least one material distinction is intentionally unresolved under the current access regime;
- `transition` — initially unresolved, then made resolvable by a later reveal/action.

At least 30% of qualification seeds must be `resolvable` and at least 30% `non_identifiable`; the remainder may be any class, including `transition`.

This prevents a system that always says "cannot tell" from scoring well merely because ambiguity was overrepresented.

## Co-primary Gate 1 outcomes

### P1 — final material conclusion quality

Each simulator world contains a hidden set of evaluation targets. For the current access regime, each target has an access-relative expected status:

- `supported`
- `rejected`
- `unresolved`

The investigator's final report must classify the same targets when they are in scope. The harness computes macro-F1 across the three statuses, plus per-status precision/recall. This is the primary end-to-end final-investigation measure.

The target statuses are never exposed to the investigator.

### P2 — true-world retention

Whether at least one candidate compatible with the hidden generating mechanism remains represented at the end of each round and at final reporting. Monolithic baselines are required to emit explicit candidate explanations so the same structural matcher can be applied.

### P3 — disconfirmation recovery

Qualification worlds contain an intentionally attractive early false explanation and a later disconfirming observation. Measure:

- whether the false explanation is explicitly rejected or removed after the disconfirmation;
- recovery latency in rounds;
- whether the replacement state preserves the true-compatible world rather than merely deleting everything.

## Guardrail outcomes

- resolution balanced accuracy across `resolvable` and `non_identifiable` cases;
- false unique-resolution rate;
- false non-resolution / over-hedging rate;
- provenance duplication inflation;
- hidden-truth leakage;
- invalid hard-constraint assertions;
- run failure rate.

Provenance and hard-constraint wins validate mechanisms but **cannot alone pass Gate 1**, because those capabilities are deliberately engineered into the deterministic core.

## Exploratory secondary outputs

- evidence-selection quality inside the controlled simulator;
- number of worlds generated/retained;
- generator recall;
- world turnover by round;
- frontier calls/tokens/cost/latency;
- local judgment count and batching ratio;
- final report auditability.

## Predeclared practical win rule

Gate 1 warrants Gate 2 only if B1 beats the stronger of B0a/B0b at the selected qualification scale under paired seed/replicate analysis as follows:

1. **P1:** at least +0.10 absolute macro-F1 in final material conclusion quality; **and**
2. **P2 or P3:** at least +0.10 absolute improvement in true-world retention or disconfirmation-recovery success, or at least one full round lower median recovery latency when both recover; **and**
3. resolution balanced accuracy is not worse by more than 0.05 absolute; **and**
4. the result is not explained by hidden-information leakage, materially larger frontier-model budget, or a weaker baseline prompt.

These are engineering/research continuation thresholds, not claims of statistical significance. They may be revised only **before** the qualification run is unblinded and the revision must be recorded.

## Negative results and scale

- Failure at `medium` or larger under a fair compute-matched baseline is evidence against the initial structured-architecture claim.
- Failure only at `small` does **not** refute the long-investigation hypothesis; record that hypothesis as `NOT_TESTED` unless a larger scale is run.
- If B0b remains near-ceiling through the largest feasible planned scale, stop the research comparison before building more architecture. A tool-only continuation would need a separate justification such as auditability/replay, not a claim of superior reasoning.

## No post-hoc threshold theater

Report per-seed and per-replicate outcomes. Do not convert this qualification study into confirmatory statistics after seeing the results.
