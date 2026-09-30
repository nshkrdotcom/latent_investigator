# Aggregation Examples

## Duplicate provenance

Evidence surfaces:

- E1: source S says “deployment occurred at 10:05”
- E2: article quotes E1
- E3: chat message paraphrases E2

Known provenance graph: `S -> E1 -> E2 -> E3`.

World W receives one semantic compatibility judgment for the canonical provenance unit. E2 and E3 add audit context but no independent score.

## Independent corroboration

- E1 from source S1
- E4 from source S2
- authenticated evidence proves S1 and S2 are independent for this fact

W may receive two evidence-unit contributions.

## Hard contradiction

World W says actor A learned X at 10:30 and used X to create message M at 10:10.

Authenticated timestamps are explicit. W is hard rejected before semantic scoring.

## Ambiguous motive

World W1: actor conceals information to protect the target.

World W2: actor conceals information to protect themselves.

Under current evidence both predict the same observations and available actions reveal no motive-specific record.

The report must retain both or state motive unresolved. A higher semantic plausibility score for one motive may rank it but does not justify saying motive is identified.
