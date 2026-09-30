# Agent Start Here

This docset is the implementation contract for a new standalone Elixir project tentatively named `latent_investigator`.

## First instruction

Do **not** begin by implementing the whole architecture.

v1.1 intentionally moves the cheap monolithic baseline forward. Build the simulator and run baseline reconnaissance before investing in the complete structured investigator.

## Required implementation order

Follow `implementation/IMPLEMENTATION_SEQUENCE.md` exactly unless code proves a reproducible contradiction.

Acceptance IDs are in `implementation/ACCEPTANCE_MATRIX.md`.

## Immutable architectural boundary for the structured arm

```text
Inference / SystemOneSDK
        │
        ▼
provider adapters
        │
        ▼
generator + bounded local evaluators
        │
        ▼
DETERMINISTIC INVESTIGATION CORE
        │
        ├── world registry
        ├── provenance graph
        ├── hard constraints
        ├── ordinal aggregation
        ├── redundancy dominance
        ├── search/pruning bookkeeping
        ├── simulator-relative acquisition scoring
        └── replay artifacts
        │
        ▼
strategic-network simulator / experiment runner
```

Model providers may propose or judge. They may never directly mutate authoritative structured-investigation state.

## Dependency contract

Use initially:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

Verify these paths resolve applications `:system_one_sdk` and `:inference`. Report a local-layout mismatch instead of silently changing the contract.

## Early kill test

After the simulator exists, implement B0a/B0b and run baseline-only scale reconnaissance. This happens **before** the full deterministic investigator core.

If a compute-matched monolithic frontier model is already near ceiling at the largest feasible intended scale, stop and report that result rather than building the remaining phases by inertia.

## Things not to build in the first pass

- Phoenix/web UI
- database
- distributed execution
- Jido/agent framework
- external datasets
- CALDERA/RCAEval/NTSB/Avalon integrations
- general plugin system
- publication statistics
- probabilistic graphical-model machinery
- calibrated Bayesian posterior claims
- automatic real-world deployment

## Required runnable outputs once implementation begins

Eventually provide:

1. a command for one complete seeded structured investigation;
2. a command for baseline reconnaissance/scale sweep;
3. a command for Gate 1 paired B0a/B0b/B1 qualification;
4. Gate 2 only if Gate 1 warrants it.

Every run writes auditable artifacts with simulator seed and model replicate separated.

## Scientific discipline

- Begin literature/novelty diligence in parallel; do not let it mutate implementation ad hoc.
- Freeze qualification scale, seeds, replicate count, prompts, batching policy, budgets, and practical win thresholds before the full Gate 1 run.
- When code exposes a contradiction, record the concrete failing case first.
- Do not start another spec-revision cycle because a prettier abstraction is imaginable.
