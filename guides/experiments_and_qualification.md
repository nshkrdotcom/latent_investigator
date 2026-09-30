# Experiments, Baselines & Qualification Gates

Latent Investigator is built to rigorously test whether structured causal search outperforms brute-force monolithic LLM execution. It includes a complete suite of experimental harnesses and qualification gates.

## Monolithic Baselines (`LatentInvestigator.Baseline.Monolithic`)

To prevent building elaborate architectures that solve problems a simple prompt could already solve, the framework evaluates two monolithic baselines:

- **B0a (Single-Pass Monolithic)**: A monolithic LLM receives all available observations in-context and directly outputs world rankings and target attributions in a single shot.
- **B0b (Iterative Compute-Matched Monolithic)**: An iterative conversational LLM arm that is allotted an identical token/compute budget to the structured arm (B1) across multiple query rounds.

---

## Qualification Progression

```text
┌─────────────────────────────────────────────────────────────┐
│ Baseline Reconnaissance (Gate 0)                            │
│ - Cheap monolithic scan on smoke/small scale.               │
│ - Kill test: If B0 is near ceiling, stop before full build. │
└──────────────────────────────┬──────────────────────────────┘
                               │ B0 fails at scale
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Gate 1: Paired Qualification (B0a vs B0b vs B1)             │
│ - Runs B1 first and measures actual token usage.             │
│ - Matches B0b compute target to B1.                         │
│ - Evaluates P1 (Target Macro-F1), P2 (True-World Retention),│
│   and P3 (Transition Recovery).                             │
└──────────────────────────────┬──────────────────────────────┘
                               │ B1 demonstrates win
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Gate 2: Evaluator Ablation                                  │
│ - Freezes frontier candidate generation.                    │
│ - Replays local judgments across Oracle, Frontier, Cheap,   │
│   and System One arms.                                      │
│ - Isolates cost, speed, and agreement to ground truth.      │
└─────────────────────────────────────────────────────────────┘
```

---

## Performance Metrics

- **P1: Target Macro-F1**: Evaluates overall accuracy in identifying the true latent actor and mechanism across all scenarios.
- **P2: True-World Retention**: Measures whether the true causal world was preserved in the beam across successive pruning rounds.
- **P3: Transition Recovery**: In `:transition` scenarios (where initial evidence is misleading), measures the fraction of runs where the investigator overturned the initial false lead once authentic witnesses were acquired.
- **Resolution Balanced Accuracy**: Prevents agents from claiming false resolution on `:non_identifiable` test cases.

---

## Diagnostic Ablations

- **Generation Bottleneck (`Experiment.GenerationBottleneck`)**: Measures the gap between end-to-end generated candidates and hidden-truth-injected candidates, determining whether downstream reasoning or initial hypothesis generation is the primary bottleneck.
- **Access Curve (`Experiment.AccessCurve`)**: Plots resolution quality as access escalates from `:public` to `:limited` to `:operator`.
- **Cost Projection (`Experiment.CostProjection`)**: Estimates call volumes and token footprints across scales and beam configurations without inventing synthetic pricing.
