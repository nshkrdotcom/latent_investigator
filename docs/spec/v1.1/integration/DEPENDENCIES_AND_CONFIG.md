# Dependencies and Configuration

## Proposed project

Working application name:

```text
:latent_investigator
```

Minimum direct dependencies for the initial scaffold:

```elixir
defp deps do
  [
    {:system_one_sdk, path: "../system_one_sdk"},
    {:inference, path: "../inference"}
  ]
end
```

Do not add provider libraries until a live `Inference` adapter is selected for the local environment. `Inference` is intentionally provider-neutral and its non-mock adapters rely on provider dependencies installed by the consuming application.

## Runtime configuration categories

The project configuration must distinguish:

### Generator client

A strong general-model `Inference.Client` used for candidate generation and attack/reframing.

Required logical config:

- adapter module
- provider
- model
- adapter options/defaults
- maximum output tokens
- timeout

### Frontier local evaluator client

An `Inference.Client` used only for bounded local judgments in Gate 1 and Gate 2.

### Cheap general evaluator client

A different `Inference.Client`, normally same provider family or another model endpoint, configured to represent the inexpensive general-model alternative.

### System One client

A `SystemOneSDK.Client` used for the System One/Jev arm.

### Simulator config

- seed
- actor count
- observation count
- round count
- channel noise configuration
- mimicry/spoof configuration
- provenance-copy configuration
- access regime

### Search config

- initial candidate count
- maximum alive worlds
- protected mechanism-family slots
- soft fit-gap limit
- attack count per round

## Configuration freezing

Every run copies its effective configuration into the run manifest before model calls begin. Environment variables and credentials are never persisted.

## Provider capability preflight

For Inference clients, call `Inference.capabilities/1` and require JSON Schema support where structured output is used. A provider that cannot prove the required response-format capability must fail preflight rather than silently fall back to free text.
