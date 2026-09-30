# Architectural Principles & Epistemic Boundaries

Latent Investigator implements a strict architectural separation of concerns designed to study structured causal investigation.

## The Tripartite Division

The system enforces an explicit boundary separating generative reasoning, bounded semantic judgment, and deterministic epistemic state:

```text
       ┌────────────────────────────────────────────────────────┐
       │             Generative Reasoning (Inference)           │
       │    - Hypothesis generation (candidate world proposals) │
       │    - Counter-hypothesis / attack world generation      │
       │    - Repair & anomaly accommodation                    │
       └───────────────────────────┬────────────────────────────┘
                                   │ proposes worlds
                                   ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    Deterministic Core (Elixir)                       │
│  - World Registry (deduplication, collision protection)              │
│  - Provenance Graph (source tracking, copy collapse, uncertainty cap)│
│  - Hard Constraint Verification (source, mechanism, chronology)      │
│  - Ordinal Compatibility Aggregator (no pseudo-Bayesian multiplication)│
│  - Diversity-Preserving Search & Pruning                             │
│  - Simulator-Relative Pair-Separation Acquisition Scoring             │
│  - Audit Logs, Run Manifests & Cryptographic Replay Engine           │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │ requests local evaluation
                                   ▼
       ┌────────────────────────────────────────────────────────┐
       │             Bounded Local Judgment Engine              │
       │    - Swappable evaluators: System One, Inference, Oracle│
       │    - Single observation / isolated claim scope         │
       │    - Diagnostic confidence output only                 │
       └────────────────────────────────────────────────────────┘
```

## Guiding Epistemic Principles

1. **Deterministic Core Owns Epistemic State**  
   Language models do not maintain the global epistemic registry, update confidence scores globally, or make pruning decisions. All world tracking, contradiction detection, and score aggregation occur deterministically in functional Elixir code.

2. **Bounded Local Judgment vs. Global Likelihood**  
   Evaluators answer narrow semantic queries:
   - Does observation $O$ support claim $C$ in world $W$?
   - Is actor $A$ capable of executing action $M$?
   Model confidence scores are treated as local diagnostic metrics. They are **never multiplied** into pseudo-Bayesian global likelihoods.

3. **Immutable State & Append-Only History**  
   Investigation state progresses strictly through append-only event logs (`events.jsonl`). Judgment IDs and evaluation results are immutable. Candidate client IDs cannot overwrite existing worlds.

4. **Zero Hidden-Truth Leakage**  
   The simulator's hidden ground truth and target identities are strictly isolated from normal investigator arms. Monolithic baselines and generative arms receive only observations permitted under the active access regime (e.g., `:public`, `:limited`, or `:operator`).

5. **Structural Integrity & Replayability**  
   Every investigation emits complete run artifacts with separated seeds (simulator seed vs. model replicate). Investigations can be deterministically replayed and verified without making network calls.
