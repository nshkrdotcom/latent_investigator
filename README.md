<div align="center">
  <img src="assets/latent_investigator.svg" alt="Latent Investigator Logo" width="200" height="200" />

  # Latent Investigator

  <p>
    <a href="https://github.com/nshkrdotcom/latent_investigator/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" /></a>
    <a href="https://elixir-lang.org"><img src="https://img.shields.io/badge/Elixir-~%3E%201.18-4B275F.svg?logo=elixir" alt="Elixir Version" /></a>
    <a href="https://hexdocs.pm/latent_investigator"><img src="https://img.shields.io/badge/HexDocs-v0.1.0-blueviolet.svg" alt="HexDocs" /></a>
    <a href="docs/spec/v1.1/README.md"><img src="https://img.shields.io/badge/Spec-v1.1%20Contract-success.svg" alt="Spec v1.1" /></a>
    <a href="https://github.com/nshkrdotcom"><img src="https://img.shields.io/badge/Research-nshkr--research-8A2BE2.svg" alt="nshkr-research" /></a>
  </p>

  <p><strong>Deterministic Epistemic Investigation Core &amp; Causal Hypothesis Exploration Engine</strong></p>
</div>

---

Latent Investigator is an Elixir research application for investigating competing causal worlds under partial observation, strategic communication, uncertain provenance, and access constraints.

The implementation follows one strict boundary throughout:

- **generative reasoning** proposes, attacks, and repairs candidate worlds through `Inference`;
- **bounded local judgment** evaluates small semantic questions through a swappable evaluator (`Inference`, System One/Jev, or an oracle fixture);
- **deterministic Elixir code** owns investigation state, provenance, hard constraints, aggregation, pruning, acquisition bookkeeping, replay, and scoring.

The application is an experimental instrument. It does not claim that evaluator confidences are causal likelihoods, that broader search necessarily improves results, or that synthetic performance establishes real-world investigative validity.

## Guides & Documentation

Explore the comprehensive guides:
- [Getting Started](guides/getting_started.md): Setup, quickstart, zero-network smoke tests, and replay.
- [Architecture & Boundaries](guides/architecture.md): Deterministic core, generative plane, and bounded evaluators.
- [Strategic Network Simulator](guides/simulator.md): Network profiles, actors, and case classes (`:resolvable`, `:transition`, `:non_identifiable`).
- [Provenance & Hard Constraints](guides/provenance_and_constraints.md): Duplicate provenance collapse, uncertainty caps, and chronology constraints.
- [Ordinal Aggregation & Search](guides/aggregation_and_search.md): Five-level ordinal aggregation, redundancy dominance, and acquisition scoring.
- [Evaluators & Generators](guides/evaluators_and_generators.md): Strict-schema candidate proposals and evaluator adapters.
- [Experiments & Qualifications](guides/experiments_and_qualification.md): Monolithic baselines (B0a/B0b), Gate 1, Gate 2, and diagnostic ablations.

## Dependencies

The Mix project intentionally declares only the two requested path dependencies:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

The paths must resolve to package roots containing the corresponding `mix.exs` files. Live `Inference` provider SDKs remain host-owned optional dependencies; inject configured `Inference.Client` values at runtime.

## What is implemented

- deterministic strategic-network simulator with smoke/small/medium/large profiles;
- `resolvable`, `non_identifiable`, and `transition` case classes;
- public/limited/operator/oracle access regimes;
- hidden truth, actor knowledge, strategic source alternatives, copied evidence, spoofable source claims, and discriminating evidence actions;
- immutable investigation/world/judgment records;
- known and uncertain provenance handling;
- authenticated-source, authenticated-mechanism, reference, capability, and chronology hard constraints;
- provenance-aware ordinal aggregation without treating model confidence as a global likelihood;
- redundancy dominance for unsupported sprawling worlds;
- diversity-preserving search pruning;
- simulator-relative pair-separation acquisition;
- `Inference` world generator/attacker with strict structured output;
- oracle, frontier/cheap `Inference`, and System One/Jev local evaluators behind one project-local contract;
- optional per-evidence batching for `Inference` judgments;
- monolithic B0a and iterative compute-matched B0b baselines;
- early baseline reconnaissance, Gate 1, Gate 2, generation-bottleneck helpers, and access-curve helpers;
- normalized run artifacts, evaluator-only truth artifacts, hashes, and zero-model-call replay;
- deterministic tests and dependency-adapter tests.

## Important environment status

This repository was authored in an environment with **no Elixir/Erlang runtime**. Source-only checks were performed, but `mix format`, compilation, ExUnit, Dialyzer, live provider calls, and experiment execution were **NOT_RUN**. See [`HANDOFF.md`](HANDOFF.md), [`SOURCE_QC_REPORT.md`](SOURCE_QC_REPORT.md), and [`docs/RUNTIME_QC.md`](docs/RUNTIME_QC.md).

## Local QC order

After arranging the sibling dependencies, the receiving agent should run:

```bash
mix deps.get
mix format
MIX_ENV=test mix compile --warnings-as-errors
mix test --warnings-as-errors
mix latent_investigator.smoke --seed 1 --persist
mix ci
```

Only after the deterministic suite is green should it configure a live frontier `Inference.Client` and run baseline reconnaissance. Gate 1 should not be the first live command.

## Commands

```bash
# no-network/model deterministic smoke
mix latent_investigator.smoke --seed 1 --persist

# live frontier model required
mix latent_investigator.baseline
mix latent_investigator.gate1

# frontier + cheap-general + System One clients required
mix latent_investigator.gate2

# frontier client required; isolates candidate-generation omission
mix latent_investigator.generation_bottleneck

# no model calls
mix latent_investigator.replay PATH_TO_RUN_DIR
```

## Specification

The complete v1.1 implementation contract is preserved unchanged under [`docs/spec/v1.1/`](docs/spec/v1.1/README.md). Implementation-specific documentation in `docs/` explains how that contract maps to this codebase.

## License

This project is licensed under the [MIT License](LICENSE) &copy; 2026 nshkrdotcom.
