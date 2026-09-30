# Model I/O Contracts

This file defines the normalized structured objects expected from `Inference` calls. The implementation should turn these into strict JSON Schemas with `additionalProperties: false` unless a specific extension field is explicitly documented.

## Candidate generation response

Top-level object:

```text
{
  worlds: [CandidateWorld...]
}
```

`CandidateWorld`:

```text
{
  client_id: string,
  summary: string,
  mechanism_family: string,
  actor_roles: [
    {actor_id: string, role: string}
  ],
  actor_knowledge: [
    {actor_id: string, fact_id: string, status: "knows" | "may_know" | "does_not_know" | "unknown", by_time: string|null}
  ],
  causal_links: [
    {from_ref: string, to_ref: string, relation: string}
  ],
  source_hypotheses: [
    {observation_id: string, source_actor_id: string|null, mechanism: string, claimed_source_status: string}
  ],
  assumptions: [string...],
  predictions: [string...],
  falsifiers: [string...]
}
```

The model may invent a new `mechanism_family` string; the core must not force every world into a predeclared taxonomy. Actor/observation references must resolve or the proposal is rejected as malformed.

## Attack response

```text
{
  weaknesses: [
    {world_id: string, issue: string, evidence_refs: [string...]}
  ],
  alternative_worlds: [CandidateWorld...]
}
```

Every alternative derived from an attack records its parent world ID in project metadata after parsing.

## Local Inference evaluator response

For `observation_compatibility` and other five-level classes:

```text
{
  value: "strongly_against" | "against" | "neutral" | "supports" | "strongly_supports",
  confidence: number|null,
  rationale: string
}
```

For source dependence:

```text
{
  value: "same_source" | "likely_related" | "unclear" | "likely_independent" | "independent",
  confidence: number|null,
  rationale: string
}
```

Rationale is for audit/debugging and must be capped to a small configured length. It is not fed back into aggregation as additional evidence.

## Monolithic baseline round response

```text
{
  worlds: [
    {id: string, summary: string, relative_support: number|null, key_evidence: [string...], assumptions: [string...]}
  ],
  rejected_explanations: [
    {summary: string, reason: string, evidence_refs: [string...]}
  ],
  provenance_concerns: [string...],
  unresolved_questions: [string...],
  non_identifiable_claims: [string...],
  next_action_id: string|null,
  conclusion: string
}
```

`relative_support` is baseline self-report only and is not assumed calibrated.

## Prompt inputs

All model calls receive explicit sections for:

- currently visible evidence;
- actor IDs and only investigator-visible actor facts;
- current surviving worlds when relevant;
- available evidence actions when relevant;
- task instructions and output schema.

No call receives simulator truth, hidden goals, hidden provenance, or oracle labels unless it is explicitly the oracle diagnostic path (which normally requires no model call anyway).
