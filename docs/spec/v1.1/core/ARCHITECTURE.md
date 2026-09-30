# Architecture

## Functional-core / model-shell design

The deterministic core owns the investigation. Model calls are bounded services around it.

```text
                         ┌─────────────────────────┐
                         │ Inference: generator    │
                         │ frontier general model  │
                         └────────────┬────────────┘
                                      │ candidate worlds / attacks
                                      ▼
┌───────────────────────────────────────────────────────────────────┐
│                     LatentInvestigator Core                        │
│                                                                   │
│ Investigation  World  Actor  Observation  Provenance  Constraint  │
│ Judgment       Aggregator      Search          Acquisition         │
│                                                                   │
│ - authoritative immutable-ish state transitions                   │
│ - chronology/capability/provenance constraints                    │
│ - ordinal world-fit aggregation                                   │
│ - world survival/pruning bookkeeping                              │
│ - evidence-action pair separation                                 │
│ - replay and artifacts                                            │
└───────────────┬────────────────────────────────┬──────────────────┘
                │ bounded local questions         │ evidence actions
                ▼                                 ▼
       ┌──────────────────────┐          ┌───────────────────────┐
       │ Evaluator behaviour  │          │ Strategic simulator   │
       ├──────────────────────┤          │ hidden true world     │
       │ Oracle               │          │ action/reveal API     │
       │ Frontier (Inference) │          └───────────────────────┘
       │ Cheap (Inference)    │
       │ System One / Jev     │
       └──────────────────────┘
```

## Why the split matters

The general model is good at generating explanations that were not explicitly enumerated, reframing a problem, and attacking a narrative. It is bad at being the sole durable store of a 150-observation investigation.

A local decision model such as Jev is designed to answer bounded semantic questions with typed outputs. It may be economical enough to evaluate many candidate/evidence pairs, but whether that helps is an empirical question.

Ordinary code is better at chronology, provenance graph operations, duplicate suppression, exact actor-access checks, deterministic replay, accounting, and preserving previous state without narrative drift.

## Authority rules

1. Provider output is never authoritative state by itself.
2. Every model output is parsed into a proposed record and validated before admission.
3. Hard simulator-known constraints override semantic fit scores.
4. Local model probabilities are not multiplied into a global posterior in the initial experiment.
5. Search pruning is a computational policy, not an epistemic declaration that a pruned world is impossible.
6. Raw provider responses are not persisted by default.
7. Every admitted world, judgment, elimination, and evidence action is traceable to the round that created it.

## Concurrency

Independent local judgments may be executed concurrently with bounded concurrency. Result ordering must be reconstructed deterministically by request ID; arrival order must never affect world scores. The first implementation may use `Task.async_stream/3` or an equivalent bounded mechanism. There is no need for a GenServer per world.

## Persistence

The initial implementation writes a filesystem run bundle. No database is required. The in-memory state is the execution state; the run bundle is the replay/audit artifact.
