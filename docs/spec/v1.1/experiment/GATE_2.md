# Gate 2 — Evaluator Quality, Cost, and Search Breadth

Run Gate 2 only after Gate 1 plumbing works and the structured architecture shows a reason to exist.

## Core question

Holding the investigator architecture and candidate-generation process fixed, how do different local evaluators affect:

- local judgment quality;
- final investigation quality;
- latency;
- provider cost;
- failure rate;
- feasible number of local judgments/worlds under a fixed resource budget?

## Evaluators

1. oracle
2. strong frontier general model through Inference
3. cheap general model through Inference
4. System One/Jev through SystemOneSDK

## Frozen workload comparison

First run all evaluators over the **same frozen set of local judgment requests**. This prevents cheaper evaluators from gaining an apparent accuracy advantage merely by exploring a different world set.

For each judgment class report:

- exact accuracy where oracle labels exist;
- ordinal absolute error;
- confusion matrix;
- missing/error rate;
- agreement with frontier evaluator on non-oracle semantic items;
- latency distribution;
- usage/cost.

## End-to-end substitution

Then rerun the complete structured investigator with only the local evaluator changed. Generator and attacker remain the same frontier configuration.

Measure Gate 1 capabilities again plus total search breadth.

## Fixed-resource breadth experiment

Only after frozen-workload quality is known, impose a fixed resource budget such as wall-clock time or measured cost. Allow each evaluator arm to use as many judgments/worlds as the budget permits.

Hypothesis under test:

> cheaper local judgments may permit broader search and thereby improve investigation quality.

Counter-hypothesis:

> noisier local judgments increase false fits and make broader search worse.

The experiment must be designed so either result is acceptable.

## System One interpretation

A useful result may be class-specific. System One may be competitive on entailment/source-dependence and weak on actor plausibility, or vice versa. Report this rather than forcing one “Jev score.”
