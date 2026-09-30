# Cost, Latency, and Scale

Cost can change the feasible search process, but that is a hypothesis to test.

## Accounting requirements

Every model-backed operation records:

- operation kind;
- provider/model;
- request ID where available;
- input/output usage;
- provider-reported cost if available;
- elapsed time;
- retry count;
- failure category;
- batch ID / batch size when applicable.

## Operation categories

- `generate_initial_worlds`
- `generate_alternative`
- `attack_world`
- `local_judgment:<kind>`
- `baseline_round`
- `report_generation`

## Mandatory pre-run cost projection

Before the Gate 1 qualification sweep:

1. materialize one deterministic medium-profile simulator world;
2. run the core with oracle/fake evaluators to count expected world-evidence judgment requests by round;
3. estimate Inference request sizes from rendered prompts without calling the live provider;
4. compute low/central/high token/call projections for B1;
5. derive the B0b compute-matched budget from the same projection;
6. run one live smoke seed to replace estimates with measured usage;
7. freeze the qualification budget before unblinding the full seed set.

If medium-scale projected cost is unreasonable, either reduce the experiment **before** running it or mark the medium/long-scale hypothesis `NOT_TESTED`. Do not silently shrink scale after seeing results.

## Judgment batching

Scoring every world/evidence pair in a separate frontier call may be wasteful and noisy.

The common evaluator layer may therefore support transport batching while preserving one logical `Judgment` record per request.

For Inference-backed evaluators, a permitted strategy is evidence-major batching: present one evidence unit with a bounded chunk of candidate worlds and request one structured judgment per world. The chunk size is configuration and must be frozen for Gate 1.

For System One, the SDK's batch facilities may evaluate repeated bounded states/questions concurrently. Provider batch/concurrency is an implementation detail; logical judgment IDs remain stable.

Batching can introduce cross-world anchoring. Therefore the implementation must include a small batch-vs-individual agreement fixture before using batching for qualification runs.

## Search breadth experiment

Gate 2 may use a resource cap:

```text
budget -> number of local judgments -> number of worlds explored -> investigation quality
```

Do not assume the curve is monotonic. More worlds plus noisy judgments may worsen false-fit survival.

## Comparable cost

A fair cheap-evaluator claim compares System One not only with a frontier model but with a cheap general model answering the same frozen judgment requests.

## No synthetic provider cost

If a provider does not report cost, leave provider cost null. An optional experiment-side estimate may be computed from an explicitly versioned price table and kept separate.
