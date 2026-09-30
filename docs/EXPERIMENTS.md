# Experiments

## Baseline reconnaissance

Run `LatentInvestigator.Experiment.Gate0` first with a live frontier client. It exercises B0a (single structured monolithic analysis) and B0b (iterative attack/revise monolithic analysis) across increasing simulator scale before relying on the structured architecture.

If a strong monolithic model remains near ceiling at the intended large scale, stop and inspect that result before spending provider budget on Gate 1.

## Gate 1

Arms:

- **B0a** — strong monolithic frontier investigator;
- **B0b** — iterative monolithic frontier investigator;
- **B1** — structured investigator with frontier generation and frontier bounded judgments.

B1 runs first for each paired case. Its reported frontier input+output tokens become B0b's target compute budget. B0b mismatch is recorded rather than hidden.

Default qualification:

- medium profile (`~40` actors / `~400` initial observations);
- `resolvable`, `non_identifiable`, and `transition` cases;
- 10 simulator seeds;
- 3 model replicates per seed;
- public access;
- local Inference judgment batching default 16 for the runner unless overridden.

Co-primary outcomes:

1. final material target macro-F1;
2. true-world retention;
3. transition/disconfirmation recovery and recovery round.

Resolution balanced accuracy is a guardrail against always-resolve or always-unresolved behavior.

The automatic continuation check implements the v1.1 practical thresholds but still requires manual review for leakage, compute mismatch, baseline quality, and anomalous traces.

## Gate 2

Generate candidates once with the frontier generator, freeze them, then replay the same local-judgment workload through:

- oracle;
- frontier Inference;
- cheap-general Inference;
- System One/Jev.

Gate 2 reports final target metrics, resource use, and exact local-judgment agreement to the oracle. It is diagnostic and should not be run as a substitute for Gate 1.

## Access curve

`Experiment.AccessCurve` creates the same simulator seed under public, limited, operator, and oracle access. It is intentionally separate from Gate 1.

## Cost projection

`Experiment.CostProjection` estimates logical judgments and transport calls before Gate 1 from scale, candidate count, rounds, seeds, replicates, and batch size. It does not invent token prices. Provider prices/costs must come from measured/live configuration.
