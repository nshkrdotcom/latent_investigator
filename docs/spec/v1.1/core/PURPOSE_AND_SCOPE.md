# Purpose and Scope

## Problem

Many investigations are not classification problems. The investigator does not know the complete hypothesis set in advance, the evidence may share hidden provenance, actors may possess different information, and the process generating observations may itself react strategically to the investigator.

The system defined here is meant to support reasoning in that regime.

It should be able to say not only:

> World A currently fits best.

but also:

> Worlds A and D remain viable; B was eliminated by chronology; C only looked corroborated because three observations derive from one source; motive is not identifiable from current access; provenance record P17 would distinguish A and D.

## Initial scope

The first implementation supports one controlled strategic-network simulator and a single complete investigation loop. It is deliberately synthetic so hidden state, source provenance, actor knowledge, causal generation, and counterfactual evidence access are known exactly.

The initial system must:

1. ingest a stream of observations;
2. propose multiple structured causal worlds;
3. retain and compare those worlds over multiple rounds;
4. track actor knowledge and source provenance;
5. enforce deterministic temporal and capability constraints;
6. obtain bounded local semantic judgments through a swappable evaluator;
7. attack leading worlds and generate materially different alternatives;
8. select evidence actions that separate surviving worlds;
9. update after new evidence;
10. emit an auditable final report containing supported conclusions, surviving alternatives, unresolved questions, and decisive missing evidence.

## Research scope

The initial research question is:

> Does an explicit persistent investigation structure produce better epistemic behavior than a strong general model reasoning monolithically over the same long, strategically contaminated evidence stream?

If Gate 1 is positive, Gate 2 asks:

> Holding the architecture and generator fixed, how do oracle, frontier-model, cheap-general-model, and System One/Jev local evaluators trade off judgment quality, final investigation quality, cost, latency, and feasible search breadth?

## Tool scope

A useful tool does not need a novel algorithm. Tool value exists if the explicit system materially improves long-running investigations, auditability, reproducibility, or cost/scale relative to a monolithic model workflow.

## Non-goals

The first implementation is not:

- a truth machine;
- a system for asserting hidden intent from ambiguous evidence;
- a surveillance or targeting system;
- a production incident-response platform;
- a replacement for domain experts;
- a benchmark claiming real-world generalization;
- a proof that Jev is calibrated for these judgments;
- a proof that more candidate worlds improve results.
