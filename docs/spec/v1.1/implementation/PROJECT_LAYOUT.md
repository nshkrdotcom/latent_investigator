# Proposed Project Layout

No files below are implemented by this docset. This is the target layout for the coding phase.

```text
latent_investigator/
  mix.exs
  config/
  lib/
    latent_investigator.ex
    latent_investigator/
      actor.ex
      observation.ex
      provenance.ex
      world.ex
      judgment.ex
      evidence_action.ex
      investigation.ex
      constraint.ex
      aggregator.ex
      acquisition.ex
      search.ex
      replay.ex
      artifact_store.ex
      evaluator.ex
      evaluator/
        oracle.ex
        inference.ex
        system_one.ex
      generator.ex
      generator/
        inference.ex
        oracle.ex
      simulator.ex
      simulator/
        strategic_network.ex
      baseline/
        monolithic.ex
      experiment/
        gate_0.ex
        gate_1.ex
        gate_2.ex
        generation_bottleneck.ex
        access_curve.ex
  test/
    ...
  priv/
    fixtures/
    prompts/
    schemas/
  tmp/
    runs/
```

## Naming discipline

Avoid multiplying packages. The initial project is one Mix application. Split packages only if actual dependency or reuse pressure appears later.

## Prompt storage

Prompts and JSON Schemas used for model calls live under version-controlled `priv/` files or modules with explicit version IDs. A run manifest records those IDs/hashes.

## Mix tasks

The eventual implementation may expose commands conceptually equivalent to:

```text
mix latent_investigator.smoke
mix latent_investigator.gate1
mix latent_investigator.gate2
mix latent_investigator.replay RUN_DIR
```

Exact task names may vary, but one-command reproducibility is required.
