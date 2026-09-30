# Evidence Acquisition

The first implementation does not claim calibrated expected information gain. Candidate-world weights are heuristic ordinal fits, not probabilities.

Instead it uses a deterministic **pair-separation heuristic** over surviving candidate worlds.

## Action prediction

The strategic simulator defines a finite evidence-action catalog. Simulator-compatible candidate worlds can predict the observable result of each action.

For action `a`, partition current alive worlds by predicted outcome signature:

```text
P_a = {bucket_1, bucket_2, ...}
```

## Separation score

With `N` alive worlds, let `pairs_total = N * (N - 1) / 2`.

Count pairs assigned to different predicted outcome buckets:

```text
separation(a) = separated_pairs / pairs_total
utility(a)    = separation(a) / max(cost_units(a), 1)
```

This uses a uniform world-count heuristic. It is not expected information gain.

## Tie breaking

Ties are broken deterministically by:

1. higher raw separated-pair count;
2. lower action cost;
3. stable action ID order.

## Important scope boundary

This acquisition result is **environment-relative**. It is clean only because the strategic-network simulator supplies a finite action catalog and simulator-compatible candidate worlds can predict action outcomes in the same schema.

Real investigations usually do not provide `predict(world, action)`. Therefore Gate 1 acquisition quality demonstrates behavior inside this controlled environment only. It is not a general real-world evidence-acquisition claim.

## Non-simulator-compatible worlds

If a candidate contains a mechanism the simulator cannot execute, the generator may provide an explicit semantic prediction for considered actions. Such predictions are marked `semantic_prediction`, never oracle. Initial Gate 1 minimizes this path so acquisition can be diagnosed cleanly.

## Acquisition oracle

The harness can compute which available action maximally separates the simulator-defined candidate worlds. Compare the investigator's selected action with this oracle to measure simulator-relative acquisition regret.

## Future work

Probability-weighted EIG becomes appropriate only if world weights have defensible probability semantics. Open-world evidence-action generation and action prediction are separate later research problems.
