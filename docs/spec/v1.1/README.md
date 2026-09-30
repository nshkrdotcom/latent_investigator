# Latent Investigator — Initial Experiment and Implementation Docset v1.1

**Status:** implementation-ready specification; no implementation has been performed.

This specification defines a small Elixir system for investigating messy causal situations in which evidence is partial, provenance matters, actors may possess different information, and some observations may have been produced strategically.

It is not a generic autonomous-agent framework and not a benchmark empire. The initial goal is one controlled strategic-network environment and a gated experiment that answers whether explicit persistent investigation structure adds value over strong monolithic frontier-model reasoning.

## Core design principle

The architecture separates three kinds of work:

1. **Generative reasoning** — propose causal worlds, invent materially different alternatives, attack leading worlds, and reframe evidence. A general language model is accessed through `Inference`.
2. **Bounded local semantic judgment** — answer small typed questions. Evaluators are provider-swappable: oracle, strong general model, cheap general model, or System One/Jev.
3. **Deterministic global state** — world registry, provenance graph, chronology, hard constraints, ordinal aggregation, minimality dominance, search bookkeeping, replay, and experiment accounting. Ordinary Elixir code is authoritative.

Models may propose or judge; they do not directly mutate authoritative investigation state.

## What v1.1 changes

v1.1 keeps the architecture and tightens the experiment before code begins:

- Gate 1 now requires improvement in final material conclusions plus retention/recovery, not bookkeeping alone.
- A compute-matched iterative monolithic baseline controls for extra model calls.
- Small/medium/large scale is explicit; a small-only negative result cannot kill a scale-dependent claim.
- Resolvable, non-identifiable, and transition worlds penalize both overconfidence and blanket hedging.
- Qualification uses repeated model runs per simulator seed.
- Baseline reconnaissance runs immediately after the simulator, before the full structured core.
- A redundancy-dominance rule blocks assumption-heavy worlds that make no new predictions.
- Cost projection and batch-vs-individual QC happen before Gate 1 qualification.
- Literature diligence begins in parallel with implementation.

See `V1_1_CHANGES.md`.

## Initial experiment

A seeded simulator creates hidden strategic-network worlds at several scales. Actors possess overlapping knowledge, heterogeneous goals, can relay or spoof messages, and may alter behavior after investigation actions. The investigator receives only the configured evidence view.

The comparison has three Gate 1 arms:

- B0a strong monolithic frontier model;
- B0b compute-matched iterative monolithic frontier model;
- B1 structured frontier investigator.

Gate 1 co-primary outcomes are:

1. final access-relative material conclusion macro-F1;
2. true-world retention;
3. disconfirmation recovery.

Resolution balance is a guardrail. Deterministic provenance bookkeeping alone cannot pass Gate 1.

If Gate 1 warrants continuation, Gate 2 compares oracle, frontier, cheap-general, and System One/Jev local evaluators under frozen workloads.

## What is intentionally not claimed

- The architecture is not assumed novel; literature diligence is active in parallel.
- Cheap local judgment is not assumed to improve quality.
- System One/Jev probabilities are not global causal likelihoods.
- Simulator acquisition results are environment-relative.
- Synthetic success does not establish real-world performance.
- A negative small-scale test does not establish that persistence cannot matter at larger scale.

## Source dependencies

Standalone Elixir project with:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

The supplied snapshots identify SystemOneSDK 0.6.0 and Inference 0.5.0. Source-backed contracts are documented under `integration/`.

## Reading order

1. `AGENT_START_HERE.md`
2. `V1_1_CHANGES.md`
3. `core/PURPOSE_AND_SCOPE.md`
4. `core/ARCHITECTURE.md`
5. `experiment/STRATEGIC_NETWORK_ENVIRONMENT.md`
6. `experiment/BASELINES.md`
7. `experiment/GATE_1.md`
8. `core/AGGREGATION.md`
9. `experiment/COST_LATENCY_AND_SCALE.md`
10. `implementation/IMPLEMENTATION_SEQUENCE.md`
11. `implementation/ACCEPTANCE_MATRIX.md`

## Stop rule

Do not expand into external datasets, UI, persistence infrastructure, multi-agent frameworks, or publication-scale experiments until Gate 1 is executed and justifies continuation. No v1.2/v2 spec cycle should begin merely from another conceptual review; require a reproducible implementation/experiment failure or a material literature finding.
