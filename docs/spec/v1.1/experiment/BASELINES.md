# Baselines

## B0a — Monolithic frontier investigator

The strongest simple baseline.

At every round it receives:

- all evidence currently available to the structured investigator;
- the same evidence-action catalog;
- its own prior round output/transcript as allowed by the configured protocol;
- the same hidden information restrictions.

It returns a structured report containing candidate explanations, material conclusions, unresolved distinctions, provenance concerns, rejected explanations, and the next evidence action.

It receives **no** externally maintained world graph, provenance graph, hard-constraint engine, or deterministic aggregator.

The prompt must not be intentionally crippled.

## B0b — Compute-matched iterative monolithic investigator

This baseline exists to separate architectural structure from simply spending more frontier-model compute.

B0b receives the same visible information and state boundary as B0a, but may use repeated calls for:

1. initial analysis;
2. adversarial attack / alternative generation;
3. evidence re-reading;
4. final revision.

The runner allocates a frontier-model budget comparable to B1 for that paired run. Preferred matching is total input+output tokens within +/-10%; if token matching is unavailable, match frontier-model call budget and report actual usage differences.

B0b may carry forward its own text transcript/output between calls. It may **not** receive the structured investigator's authoritative world registry, provenance graph, hidden constraint results, or local evaluator outputs.

## B1 — Structured frontier investigator

Frontier general model for:

- candidate-world generation;
- attack/reframing;
- local judgments.

Deterministic core for everything else.

This is the Gate 1 comparison arm.

## B2 — Structured + oracle local evaluator

Frontier generator/attacker; oracle local judgments. Diagnostic ceiling on evaluator quality.

## B3 — Structured + cheap general evaluator

Frontier generator/attacker; small/cheap general model for local judgments through Inference.

## B4 — Structured + System One/Jev evaluator

Frontier generator/attacker; System One/Jev for local judgments through SystemOneSDK.

## B5 — Generation oracle

Inject the true structured world into the candidate set while keeping the selected local evaluator unchanged. This is an ablation for generation omission, not a deployable solver.

## Fairness and budgets

### Gate 1

Report both B0a and B0b. The primary structured comparison is against the **stronger** of them on each predeclared primary outcome.

All Gate 1 arms receive identical visible evidence and action availability. B0b controls for additional frontier-model compute. B1 is still allowed deterministic bookkeeping that the baseline lacks because that is the architecture under test; however, bookkeeping-only metrics cannot establish a Gate 1 win.

### Gate 2

Evaluator comparisons freeze:

- candidate worlds;
- generator outputs;
- local judgment request set;
- aggregation;
- search policy;
- evidence budget.

A later fixed-dollar or fixed-latency experiment may measure how many worlds each evaluator permits, but search breadth is an outcome, not an entitlement.
