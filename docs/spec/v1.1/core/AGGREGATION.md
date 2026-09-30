# Deterministic Aggregation

This is the initial global scoring rule. It is intentionally simple and intentionally **not Bayesian**.

Local model confidences are not established as calibrated likelihood terms, and repeated judgments from the same model are correlated. Multiplying them would create false precision.

## Step 1 — hard constraints

Before semantic scoring, reject any world that violates an explicit deterministic fact, including:

- impossible chronology;
- impossible actor access or capability;
- contradiction with authenticated simulator evidence;
- malformed causal references;
- impossible action/source identity under revealed provenance.

A hard rejection is recorded with a machine-readable reason. It cannot be compensated for by semantic support elsewhere.

## Step 2 — provenance grouping

Observations known to derive from the same provenance root do not receive independent additive weight.

For each known provenance component `g`, construct one canonical evidence unit. Direct copies, quotations, and paraphrases remain visible in the audit trail but add no extra independent score.

When dependence is suspected rather than established, the component is marked `uncertain_dependence`; its total contribution is capped to the magnitude of one evidence unit until resolved.

## Step 3 — local compatibility

For each alive world `w` and each independent evidence unit `g`, obtain exactly one `observation_compatibility` ordinal weight:

```text
strongly_against  -2
against           -1
neutral             0
supports           +1
strongly_supports +2
```

The request may summarize multiple surface observations that belong to the same provenance unit. Other local judgment classes are not added to this score, preventing correlated semantic questions from being counted repeatedly.

## Step 4 — world fit

For `G` independent evidence units:

```text
raw_fit(w) = sum(weight(w, g) for g in G)
fit(w)     = raw_fit(w) / (2 * |G|)
```

Therefore `fit(w)` lies in `[-1, 1]` when at least one evidence unit exists.

This score is used for ranking and search management only. It is not a posterior probability.

## Step 5 — redundancy dominance / minimality tie-break

The initial experiment does **not** add an arbitrary numeric complexity penalty.

Instead, define a deterministic dominance relation. World `w_big` is redundancy-dominated by `w_small` when all of the following hold over the currently visible evidence and available action catalog:

1. `w_big` and `w_small` make the same material predictions;
2. they explain the same evidence units with the same compatibility pattern;
3. `w_big` contains a strict superset of unsupported assumptions/latent entities/causal edges;
4. the extra structure in `w_big` changes no current prediction and creates no additional falsifier.

When this relation is proven structurally, rank `w_small` ahead of `w_big` and record `redundancy_dominated_by`. Do not delete `w_big` solely for complexity unless the search policy needs space; preserve it in history.

This blocks the trivial strategy "add assumptions until every observation has a story" without claiming a universal Occam prior.

## Step 6 — survival and pruning

Hard-rejected worlds are removed from the active set.

Soft pruning is controlled by:

- `max_alive_worlds`
- `fit_gap_limit`
- `protected_diversity_slots`

A world may be retained despite lower fit when it is the only representative of a materially different mechanism family. Every soft-pruned world remains in history and may be revived after later evidence or attack.

The default initial experiment should preserve alternatives rather than aggressively optimize speed.

## Step 7 — report uncertainty honestly

No fit threshold authorizes the phrase “proven true.” Final reporting distinguishes:

- hard contradiction;
- better current fit;
- surviving alternative;
- unresolved because current evidence does not separate worlds;
- unresolved because the generator may have omitted alternatives.

## Oracle/adversarial tests before model runs

Required fixtures:

1. duplicate evidence does not increase fit merely because it was copied;
2. an authenticated contradiction rejects the incompatible world regardless of other support;
3. two observationally identical worlds remain tied until discriminating evidence appears;
4. the true world is not guaranteed top rank when revealed evidence genuinely favors another world under the ordinal rubric;
5. larger candidate sets do not receive a hidden score bonus;
6. a sprawling world that adds unsupported assumptions but changes no predictions cannot outrank its strict simpler counterpart;
7. a genuinely more complex world **can** outrank a simpler one when its extra structure makes a material prediction that fits new evidence.

## Later extensions

Calibrated likelihood aggregation, learned weights, Bayesian model comparison, or evaluator-specific calibration may be explored only after the initial ordinal system is measured. They are not prerequisites for Gate 1.
