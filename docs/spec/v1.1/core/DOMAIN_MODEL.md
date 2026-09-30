# Domain Model

The names below are implementation contracts, not suggestions for a giant object hierarchy. They should become small Elixir structs or equivalent immutable maps.

## Investigation

Required fields:

| Field | Meaning |
|---|---|
| `id` | stable run-local investigation ID |
| `round` | zero-based evidence round |
| `observations` | admitted observation registry |
| `actors` | actor registry |
| `worlds` | candidate-world registry |
| `judgments` | bounded local-judgment registry |
| `provenance` | provenance graph |
| `actions` | available and executed evidence actions |
| `history` | ordered state-transition events |
| `config` | frozen run configuration |

## Actor

Required fields:

- `id`
- `public_profile`
- `capabilities`
- `known_facts` — only present in simulator truth; investigator has a separate believed-knowledge representation
- `goals` — hidden in simulator truth unless evidence reveals them
- `channel_access`
- `relationships`

The investigator must never receive simulator-only fields except under an explicit oracle access regime.

## Observation

Required fields:

- `id`
- `round`
- `timestamp`
- `surface` — the text or event visible to the investigator
- `observation_type`
- `claimed_source`
- `authenticated_source` — optional and normally hidden
- `provenance_ref` — investigator-known provenance, if any
- `access_level`
- `metadata`

## Provenance node and edge

A provenance node identifies an underlying information source or event. An observation may be a direct view, quotation, paraphrase, relay, transformation, or spoof of another node.

Edge types in the initial environment:

- `:derived_from`
- `:quoted_from`
- `:paraphrased_from`
- `:copied_from`
- `:spoofed_as`
- `:independent_of`

Only relationships actually known to the investigator belong in the authoritative investigator graph. The simulator holds a complete hidden provenance graph for scoring.

## Candidate world

A world is a structured causal proposal, not merely prose.

Required fields:

- `id`
- `summary`
- `mechanism_family`
- `actor_roles` — proposed actor-to-role assignments relevant to the case
- `actor_knowledge` — proposed claims about who knew what by what time
- `causal_links` — proposed cause/effect relations
- `source_hypotheses` — proposed origins for strategically important observations
- `assumptions`
- `predictions`
- `falsifiers`
- `generation` — round, generator model, parent/attack origin
- `status` — `:alive | :rejected | :pruned | :merged`
- `fit_score`
- `hard_failures`

A world may also carry free-form notes. The structured fields are the execution interface.

## Local judgment

Required fields:

- `id`
- `kind`
- `subject_ref`
- `world_id`
- `observation_id` or relevant target
- `value`
- `ordinal_weight`
- `provider`
- `model`
- `provider_confidence` — optional; never interpreted as a global likelihood
- `distribution` — optional
- `latency_ms`
- `usage`
- `cost`
- `round`

## Evidence action

An evidence action represents a query the environment can answer, such as authenticating a sender, revealing a provenance edge, disclosing a timestamped access log, or exposing one actor-knowledge fact.

Required fields:

- `id`
- `kind`
- `cost_units`
- `availability`
- `target_ref`
- `description`

The simulator implements `predict(world, action)` for simulator-compatible candidate worlds and `execute(true_world, action)` for the hidden world.
