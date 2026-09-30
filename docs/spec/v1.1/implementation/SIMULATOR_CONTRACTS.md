# Simulator Contracts

The strategic-network simulator is a controlled experimental environment, not an autonomous agent society.

Conceptual behaviour:

```elixir
@callback new(seed(), profile(), case_class(), access_regime()) :: {:ok, env()} | {:error, term()}
@callback initial_observations(env()) :: [Observation.t()]
@callback available_actions(env(), Investigation.t()) :: [EvidenceAction.t()]
@callback execute(env(), EvidenceAction.t()) :: {:ok, env(), [Observation.t()]} | {:error, term()}
@callback predict(candidate_world(), EvidenceAction.t()) :: {:ok, outcome_signature()} | :unsupported
@callback hidden_truth(env()) :: hidden_truth()
@callback evaluation_targets(env()) :: [evaluation_target()]
@callback match_world(hidden_truth(), candidate_world()) :: world_match()
```

Exact callback names may differ, but the capabilities must exist.

## Environment state

The simulator privately owns:

- hidden actor knowledge;
- hidden actor goals;
- true source/provenance graph;
- true event graph;
- channel-delivery state;
- access-controlled evidence artifacts;
- case class (`resolvable | non_identifiable | transition`);
- hidden access-relative evaluation targets;
- current round;
- deterministic RNG state/seed.

## Observation reveal

`initial_observations/1` and `execute/2` return only masked observations allowed by the configured access regime.

## Evaluation targets

Each target has at least:

```text
{
  target_id,
  proposition,
  expected_status_by_regime_or_round: supported | rejected | unresolved
}
```

These records are hidden from normal investigator code and available only to the evaluation harness.

## Prediction

`predict/2` evaluates what a simulator-compatible candidate world says an evidence action would reveal. This powers deterministic pair-separation acquisition.

It must not consult the hidden true world except when the candidate itself is the true-world object in an oracle diagnostic.

This capability is a simulator affordance, not assumed to exist in real investigations.

## World matching

The hidden-world matcher returns structured diagnostics:

```text
{
  compatible: boolean,
  mechanism_match: boolean,
  actor_assignment_match: number in [0,1],
  information_flow_match: number in [0,1],
  provenance_mechanism_match: number in [0,1],
  mismatches: [...]
}
```

Freeze this matcher before Gate 1 qualification results are interpreted.

## Surface generation

Surface messages may be template-rendered in v1.1. If an LLM renderer is later added, it receives a code-generated event description and may vary wording only; it may not decide actor identity, causal source, hidden intent, or provenance after the fact.
