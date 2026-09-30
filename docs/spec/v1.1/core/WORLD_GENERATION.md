# World Generation

World generation is a first-class experimental bottleneck. Cheap local judgments cannot rescue a causal world that was never proposed.

## Provider

The initial generator uses a strong general model through `Inference`. It must request strict structured output so candidate worlds can be validated by ordinary code.

## Generation modes

### Initial fan-out

Given the initial observations, generate `K_initial` materially different worlds. Diversity must be requested in causal mechanism, actor role, source/provenance hypothesis, and information-flow path — not merely wording.

### Attack-derived generation

Given a leading world, ask for the strongest materially different alternative that preserves all hard facts while changing at least one important causal mechanism.

### Missing-mechanism generation

When surviving worlds overuse the same mechanism family, ask explicitly for explanations outside those families.

### Repair generation

When new evidence rejects a world, the generator may produce a repaired descendant only if it declares what changed. The parent remains in history as rejected; it is never silently overwritten.

## Required structured output

Each proposed world must provide the fields in `core/DOMAIN_MODEL.md`. The generator may include free-form rationale, but admissions are based on the structured record.

## Deduplication

Two proposals are duplicates when their execution-relevant structured fields are equivalent after canonical sorting and normalized IDs. Narrative wording never makes a duplicate into a new world.

## Generation oracle

The simulator can inject the hidden true world into the candidate set without revealing that fact to the investigator. This is the **generation oracle** arm.

Comparing actual generation with generation-oracle runs isolates the loss attributable to candidate omission.

## Generation metrics

- `true_world_recall@K`
- unique valid worlds generated
- structural duplication rate
- mechanism-family diversity
- number of generator calls
- frontier-model tokens/cost/latency
- recovery: rounds required to generate the true mechanism after disconfirming evidence

## Important interpretation

A larger world set is not presumed better. More worlds create more opportunities for noise to fit by chance and increase evaluator load. Search breadth is therefore measured jointly with true-world retention, false-world survival, and total cost.
