# Acceptance Matrix

## Foundation / simulator

| ID | Requirement |
|---|---|
| F01 | Project resolves requested `system_one_sdk` and `inference` path dependencies. |
| F02 | Simulator can execute with zero network/model access. |
| F03 | Hidden simulator truth/evaluation targets never appear in normal investigator or baseline request payloads. |
| F04 | Same seed/profile/case class reproduces identical hidden world and reveal stream. |
| F05 | Simulator generates `resolvable`, `non_identifiable`, and `transition` cases. |
| F06 | Pure replay reproduces simulator and final investigation state hashes. |

## Early baseline

| ID | Requirement |
|---|---|
| B01 | B0a returns schema-valid candidate explanations and final material target statuses. |
| B02 | B0b supports iterative attack/revise passes without external structured state. |
| B03 | Baseline-only scale reconnaissance runs before full structured core implementation. |
| B04 | Baseline model replicate IDs and provider usage are recorded separately from simulator seed. |

## Core reasoning

| ID | Requirement |
|---|---|
| C01 | Hard chronology contradiction rejects a world deterministically. |
| C02 | Known duplicate provenance contributes no extra independent score. |
| C03 | Uncertain dependence is capped and explicitly labeled. |
| C04 | Fit aggregation matches hand-computed ordinal fixtures. |
| C05 | Designed observationally compatible worlds remain both alive before discriminating evidence. |
| C06 | Later discriminating evidence can reject the incompatible world without rewriting history. |
| C07 | Acquisition heuristic chooses the hand-computed best separator on fixture worlds. |
| C08 | A strictly more assumption-heavy world with identical predictions cannot outrank its simpler counterpart. |
| C09 | Additional complexity is allowed to win when it changes material predictions and fits new evidence. |

## Generation

| ID | Requirement |
|---|---|
| G01 | Inference generator emits validated structured worlds. |
| G02 | Duplicate structured worlds are detected independent of narrative wording. |
| G03 | Attack-derived world records parent lineage and changed assumptions. |
| G04 | Generation oracle can inject true world only through experiment diagnostic path. |
| G05 | Generation recall metrics are computed against simulator structural truth. |

## Evaluators

| ID | Requirement |
|---|---|
| E01 | Oracle, frontier, cheap-general, and System One arms implement one common contract. |
| E02 | Inference evaluator uses strict structured output or fails preflight. |
| E03 | System One evaluator uses actual SDK semantic primitives and records response metadata. |
| E04 | Provider confidence/distributions are logged but not multiplied into global likelihoods. |
| E05 | Errors remain errors; no silent neutral fallback. |
| E06 | Agreement/error metrics are reported by judgment class. |
| E07 | Judgment-state builders send bounded relevant slices rather than whole investigation state by default. |
| E08 | Batch-vs-individual fixture reports agreement and batching metadata before qualification use. |

## Gate 1

| ID | Requirement |
|---|---|
| Q01 | B0a/B0b/B1 receive identical visible evidence and action availability. |
| Q02 | Baseline prompts are versioned and not intentionally weakened. |
| Q03 | B0b receives a frontier-model budget matched to B1 within the documented tolerance or mismatch is reported. |
| Q04 | Qualification includes all case classes and satisfies minimum resolvable/non-identifiable proportions. |
| Q05 | At least 3 model replicates per seed are recorded unless provider determinism is explicitly demonstrated. |
| Q06 | Gate 1 records P1 final material conclusion quality, P2 true-world retention, and P3 disconfirmation recovery. |
| Q07 | Provenance bookkeeping alone cannot satisfy Gate 1 continuation rule. |
| Q08 | Pre-run cost projection, batching policy, scale, seeds, prompts, and thresholds are frozen before qualification. |
| Q09 | Gate 1 conclusion can be reached without Gate 2 evaluator assumptions. |

## Gate 2

| ID | Requirement |
|---|---|
| R01 | Frozen local-judgment request set can be replayed through all evaluator arms. |
| R02 | Candidate generator/attacker outputs remain fixed during local-evaluator comparison. |
| R03 | Cheap-general arm is included beside System One. |
| R04 | Fixed-resource breadth experiment reports both quality and number of worlds/judgments. |
| R05 | Search breadth is not described as beneficial unless measured outcome supports it. |
