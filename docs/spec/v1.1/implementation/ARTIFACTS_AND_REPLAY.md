# Artifacts and Replay

Every run writes to:

```text
tmp/runs/<run_id>/
```

## Required files

- `manifest.json` — frozen config, dependency versions/hashes, simulator seed, model replicate, scale/profile, case class, model identities, prompt/schema/batching hashes, budgets
- `truth.json` — simulator hidden truth and hidden evaluation targets; evaluator-only
- `observations.jsonl` — observations in reveal order
- `events.jsonl` — authoritative investigation transitions
- `worlds.jsonl` — world creation/status/lineage events
- `judgments.jsonl` — normalized local judgments with logical request ID and batch metadata
- `actions.jsonl` — evidence actions considered/executed
- `rounds/<n>.json` — compact round snapshot
- `report.json` — normalized final report
- `metrics.json` — computed metrics including co-primary Gate 1 outcomes
- `trace_summary.jsonl` — redacted provider/model/usage/latency metadata

Qualification groups also write a parent experiment directory containing:

- frozen seed list;
- model replicate list;
- prompts/schemas and hashes;
- pre-run cost projection;
- compute-matching policy;
- batching policy;
- practical Gate 1 thresholds;
- paired summary table.

## Replay modes

### Pure replay

Rebuild investigation state from recorded normalized events without model calls. Must reproduce final state hashes.

### Provider replay

Optional/non-deterministic: rerun model calls using recorded normalized requests. Used for drift studies.

## Hidden-truth separation

The experiment scorer may read `truth.json`. Baseline and investigator modules receive only masked environment views. Tests prove hidden truth and expected target labels are absent from model request serialization.

## Hashing

Use SHA-256 for prompt files, schema files, simulator configuration, batching policy, qualification freeze file, and final state snapshots. Canonicalize serialization before hashing.
