# Decision Log

## D01 — Three-layer architecture

Separate generative reasoning, bounded local judgment, and deterministic global investigation state.

## D02 — Jev in the first implementation, but not as a premise

System One/Jev is implemented behind the evaluator interface from the start, yet Gate 1 does not depend on it. This isolates architecture value from evaluator quality.

## D03 — Cheap general model is mandatory in Gate 2

A Jev cost claim must be compared with the actual cheap general-model alternative, not only with a frontier model.

## D04 — No global probability multiplication initially

Local model probabilities are correlated and not established as likelihood factors. Initial aggregation uses a fixed ordinal fit rule plus deterministic hard constraints and provenance grouping.

## D05 — Search breadth is an empirical variable

Cheaper judgment may enable more worlds, but more noisy worlds may worsen false-fit survival. Gate 2 tests both possibilities.

## D06 — World generation is separately measured

The generator can be the dominant bottleneck. Generation-oracle injection and recall metrics are required.

## D07 — Initial environment is one strategic network

Do not begin with seven external datasets. External environments are later validation layers.

## D08 — No another-document-loop rule

The next major architectural revision should be triggered by executable contradiction or measured failure, not by another purely conceptual review.
