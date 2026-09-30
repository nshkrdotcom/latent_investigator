# System One / Jev Integration

System One is used only for bounded local semantic judgments. It does not generate candidate worlds and it does not own global scores.

## Source-backed API

The attached SDK exposes:

```elixir
client = SystemOneSDK.new_client(...)
prepared = SystemOneSDK.prepare!(...)
{:ok, response} = SystemOneSDK.evaluate(client, state, prepared, opts)
answer = SystemOneSDK.Response.fetch!(response, id)
metadata = SystemOneSDK.Response.metadata(response)
```

Strict question constructors are available through:

```elixir
SystemOneSDK.noul(...)
SystemOneSDK.choice(...)
SystemOneSDK.score(...)
```

The attached SDK also exposes bounded batch evaluation through `SystemOneSDK.Batch.stream/4` and `SystemOneSDK.Batch.many/4`. Batch use is optional and must preserve project-local judgment IDs and the qualification batching policy.

## Mapping judgment classes

### Observation compatibility — Score, additive v1 fit input

Use a five-level Score in this exact order:

1. `strongly_against`
2. `against`
3. `neutral`
4. `supports`
5. `strongly_supports`

Map the enriched/expected score level to `-2..+2`. Preserve provider distribution/confidence for Gate 2 analysis, but never treat it as a global likelihood.

### Source dependence — Choice, provenance policy input

Fixed domain:

- `same_source`
- `likely_related`
- `unclear`
- `likely_independent`
- `independent`

Model-inferred dependence remains uncertain provenance and may be overridden by authenticated evidence.

### Semantic entailment / textual contradiction — Noul or Choice, non-additive

Support attack, explanation, and diagnostics; do not independently add to world fit.

### Actor behavior / mechanism plausibility — Score, non-additive

Use a fixed five-level plausibility rubric where useful. Measure these in Gate 2; do not sum them into v1.1 world fit.

## Bounded state is mandatory

A System One request should describe one local question, not dump the whole world registry or 150–1000 observation history.

Construct the smallest material state containing:

- the relevant world claim/assumption;
- the relevant actor knowledge/goal slice;
- the evidence/provenance unit being judged;
- minimal temporal/context facts required by the rubric.

Record serialized state size. If the request cannot fit the provider/model constraints, return an explicit evaluator error. Do not silently truncate.

## Prepared sets and batching

Where instructions/rubrics are fixed and only state changes, create prepared question sets once and reuse them.

If batch evaluation is enabled, use SDK batch facilities/concurrency rather than inventing provider-internal semantics. One batch result still maps to one project-local Judgment per state/request.

## Metadata to persist

Persist stable summary metadata:

- model returned by response;
- request ID;
- usage;
- elapsed time;
- retry count;
- prepared fingerprint;
- state-size estimate;
- batch index/size where applicable.

Do not persist credentials or unnecessary raw provider request state.

## Model identity

Development runs may use SDK default alias. Gate 2 comparison runs record the concrete model reported in each response. Prefer pinned model IDs if available.

## Calibration discipline

The experiment does not assume provider confidence is calibrated for these judgment classes. Gate 2 compares System One outputs against oracle labels where available and against the strong evaluator on intrinsically fuzzy cases, class by class.
