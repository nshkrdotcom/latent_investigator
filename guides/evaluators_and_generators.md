# Evaluators & World Generators

Latent Investigator isolates all stochastic model interactions behind clean, typed boundaries for generation and evaluation.

## Generative Plane (`LatentInvestigator.Generator`)

Candidate hypotheses are proposed, attacked, and repaired using structured language models via the `Inference` package.

### Strict JSON Schema Output
All generation prompts enforce strict JSON schema decoding:
- Proposing new candidate worlds from initial evidence (`Generator.Inference.propose/3`).
- Generating targeted counter-hypotheses and adversarial attack worlds (`Generator.Inference.attack/3`).
- Repairing existing hypotheses to account for newly discovered anomalies (`Generator.Inference.repair/3`).

Malformed responses fail fast and do not corrupt the deterministic core state.

### Attack Lineage & Parent Tracking
When an attack world is spawned to challenge an existing hypothesis, the relationship is recorded via parent world IDs (`parent_world_id`). This preserves the lineage of dialectical inquiry for replay and audit analysis.

---

## Local Evaluators (`LatentInvestigator.Evaluator`)

Rather than asking an LLM to evaluate an entire complex scenario in a monolithic context window, the system breaks evaluation into atomic, bounded judgment queries:

```elixir
defmodule LatentInvestigator.Evaluator.JudgmentRequest do
  @type t :: %__MODULE__{
    id: String.t(),
    world: LatentInvestigator.World.t(),
    observation: LatentInvestigator.Observation.t(),
    focus: :source | :mechanism | :chronology | :consistency
  }
end
```

### Swappable Evaluator Implementations

1. **`Evaluator.Oracle`**  
   Consults the simulator's deterministic ground truth. Used for zero-network smoke tests, offline validation, and establishing theoretical upper bounds.

2. **`Evaluator.Inference`**  
   Evaluates claims using LLM completions via `Inference.complete/3`. Supports both frontier models (e.g., GPT-4o, Claude 3.5 Sonnet) and cheaper generalist models (e.g., Haiku, GPT-4o-mini).

3. **`Evaluator.SystemOne`**  
   Integrates with System One SDK primitives (`evaluate/4`, `choice/3`, `score/3`, `noul/2`) for specialized semantic judgment without whole-investigation context overhead.

### Same-Evidence Batching
When multiple candidate worlds need evaluation against the same newly acquired observation, `Evaluator.Inference` supports batched prompt completion while maintaining distinct logical request IDs and separate transport call accounting.
