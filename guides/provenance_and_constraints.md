# Provenance Tracking & Hard Constraints

A core vulnerability in unstructured LLM investigation is susceptibility to echo chambers (redundant copies of the same unverified rumor treated as independent corroboration) and temporal hallucinations. Latent Investigator implements rigorous provenance tracking and deterministic hard constraint checking.

## Provenance Tracking (`LatentInvestigator.Provenance`)

Every observation ingested by the investigation core carries explicit provenance metadata:

```elixir
%LatentInvestigator.Observation{
  id: "obs_019",
  source_actor_id: "actor_echo",
  timestamp: ~U[2026-09-30 12:00:00Z],
  provenance: %LatentInvestigator.Provenance{
    root_source_id: "actor_rumor_hub",
    hop_count: 2,
    authenticated: false,
    cluster_id: "cluster_claim_42"
  }
}
```

### Collapse of Known Duplicate Provenance
When multiple observations share an identical root source or causal transmission cluster, the core treats them as dependent. Additional redundant reports do not add independent support to a hypothesis.

### Uncertain Dependence Cap
In real-world settings, provenance trees may be partially obscured. The investigator identifies groups of observations whose mutual independence is uncertain. To prevent echo chambers from artificially inflating support:
- Uncertain clusters contribute at most `0.5` points of effective aggregate weight toward any hypothesis.
- Independent, authenticated corroboration is required to achieve full confidence.

---

## Hard Constraints (`LatentInvestigator.Constraint`)

Before any candidate world undergoes costly semantic evaluation or ordinal ranking, it must pass deterministic hard constraint verification. A candidate that violates a hard constraint is immediately refuted without spending LLM tokens.

### 1. Authenticated Source Constraint
If an event is witnessed by a cryptographically or physically authenticated source, candidate worlds claiming an incompatible source for that specific event are rejected.

### 2. Authenticated Mechanism Constraint
If forensic telemetry confirms a specific vector (e.g., zero-day exploit vs. credential stuffing), candidate worlds asserting an incompatible mechanism are marked refuted.

### 3. Chronology Constraint
A world cannot attribute causal action to information that was not yet created at the time of the event. If an actor's knowledge acquisition postdates the attributed incident, the world violates the chronology constraint.

### 4. Actor Capability & Access Constraint
A candidate world asserting that actor $A$ performed action $M$ requiring privilege $P$ is immediately invalidated if $A$ lacks that privilege in the verified actor registry.
