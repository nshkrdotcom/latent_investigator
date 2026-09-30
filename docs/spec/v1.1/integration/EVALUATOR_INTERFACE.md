# Evaluator Interface

The project defines one local behaviour independent of provider.

Conceptual callbacks:

```elixir
@callback judge(Evaluator.Context.t(), JudgmentRequest.t()) ::
  {:ok, Judgment.t()} | {:error, term()}

@callback judge_many(Evaluator.Context.t(), [JudgmentRequest.t()]) ::
  {:ok, [Judgment.t()]} | {:error, term()}
```

`judge_many/2` is an optional transport optimization; implementations may default to repeated `judge/2`. Logical semantics remain one judgment per request.

No provider-specific struct crosses this boundary.

## JudgmentRequest

Required fields:

- `id`
- `kind`
- `state` — normalized **bounded** semantic state
- `rubric`
- `world_id`
- `subject_refs`
- `round`

The request must be deterministic and serializable. It must not contain credentials or simulator hidden truth unless the evaluator is the oracle arm.

## Bounded-state rule

A local judgment receives only the material slice required for that judgment: relevant world assumptions, referenced actor state, one evidence/provenance unit, and any explicit rubric context. Do not send the entire investigation history by default.

If a provider limit cannot accommodate the bounded state, fail/record the judgment rather than silently truncating material input.

## Evaluator implementations

### Oracle

Uses simulator truth or hand-authored fixtures. No model calls.

### Frontier Inference

Uses a configured strong general model via `Inference.complete/3` with strict JSON Schema output.

### Cheap general Inference

Identical logical prompt/schema path to Frontier Inference; only configured client/model differs.

### System One

Maps each judgment class onto System One primitives. Fixed question/rubric definitions should be reused where feasible and case-specific data placed in bounded state.

## Fairness rule

All non-oracle evaluators receive semantically equivalent state/rubrics. Provider-specific wording may be minimally adapted to API shape, but no arm receives additional hidden facts or richer context.

## Batching rule

Batching may reduce transport overhead but can introduce cross-item anchoring for general LLMs. Qualification runs freeze batch strategy/chunk size and record it. A batch-vs-individual fixture is required before relying on batching.

## Failure behavior

A failed local judgment never becomes a neutral answer silently. Record `judgment_error`; aggregation either leaves the evidence unit unscored for that world or fails the run according to frozen experiment configuration. The denominator must not change invisibly.
