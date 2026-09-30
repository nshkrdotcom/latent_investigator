# Getting Started

Welcome to **Latent Investigator**, an Elixir research application for investigating competing causal hypotheses under partial observation, strategic communication, uncertain provenance, and access constraints.

## System Requirements

- **Elixir**: `~> 1.18`
- **Erlang/OTP**: `27` or later recommended
- **Dependencies**: Sibling package roots for `:system_one_sdk` and `:inference`

## Quick Start (Zero-Network Deterministic Smoke)

Latent Investigator can be run in a 100% deterministic, zero-network smoke mode that exercises the entire pipeline (simulator, candidate generation, bounded judgments, hard constraints, ordinal aggregation, and report generation) using deterministic oracles without external model credentials:

```bash
# Fetch dependencies
mix deps.get

# Run the deterministic smoke investigation and persist artifacts
mix latent_investigator.smoke --seed 1 --persist
```

This command executes an investigation on the `:smoke` profile of the strategic-network simulator and outputs run artifacts into a timestamped directory under `tmp/runs/`.

### Replaying an Investigation

All investigations generate self-contained, auditable artifacts. You can replay any persisted run directory to verify hashes and reproduce conclusions without invoking any model:

```bash
mix latent_investigator.replay tmp/runs/smoke_seed_1_<timestamp>
```

The replay engine reads:
- `manifest.json`: Configuration, seeds, model identifiers, and prompt versions.
- `state.json`: Normalized investigation state at each step.
- `events.jsonl`: Append-only event history.
- `report.json`: Final ranking and discrimination metrics.
- `evaluation.json`: Ground truth comparison and target attribution.
- `hashes.json`: Cryptographic integrity checksums.

## Provider Configuration for Live Runs

When you are ready to evaluate live models, configure the client modules in your environment or via runtime application configuration:

### Frontier & Cheap Inference Clients

Latent Investigator uses `Inference.Client` for candidate generation, attack/repair passes, and monolithic baseline models:

```elixir
# In config/runtime.exs or test scripts:
frontier_client = Inference.Client.new!(adapter: Inference.Adapters.OpenAI, api_key: System.fetch_env!("OPENAI_API_KEY"), model: "gpt-4o")
cheap_client = Inference.Client.new!(adapter: Inference.Adapters.Anthropic, api_key: System.fetch_env!("ANTHROPIC_API_KEY"), model: "claude-3-5-haiku")

Application.put_env(:latent_investigator, :frontier_inference_client, frontier_client)
Application.put_env(:latent_investigator, :cheap_inference_client, cheap_client)
```

### System One SDK Client

For bounded semantic judgments with System One:

```elixir
system_one_client = SystemOneSDK.new_client(api_key: System.fetch_env!("SYSTEM_ONE_API_KEY"))
Application.put_env(:latent_investigator, :system_one_client, system_one_client)
```

## Running Experiments

Latent Investigator provides dedicated Mix tasks for running baseline reconnaissance and qualification experiments:

```bash
# Baseline reconnaissance (monolithic LLM against synthetic network)
mix latent_investigator.baseline

# Gate 1 paired qualification (B0a vs B0b vs B1 structured investigator)
mix latent_investigator.gate1

# Gate 2 local evaluator comparison (Inference vs System One vs Oracle)
mix latent_investigator.gate2

# Candidate generation bottleneck ablation
mix latent_investigator.generation_bottleneck
```
