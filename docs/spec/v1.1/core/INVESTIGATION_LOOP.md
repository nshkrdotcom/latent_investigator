# Investigation Loop

The loop is the experiment. Do not replace it with a single agent prompt.

## Round 0

1. Create or load the hidden simulator world.
2. Reveal the initial observation set permitted by the configured access regime.
3. Parse and admit observations.
4. Ask the generator for an initial diverse set of candidate worlds.
5. Validate and deduplicate candidate structures.
6. Apply deterministic hard constraints.
7. Obtain required local judgments for surviving worlds.
8. Aggregate world fit.
9. Run the attack step against leading and strategically distinct worlds.
10. Admit materially new worlds produced by attack/reframing.
11. Re-evaluate as needed.
12. Select the next evidence action.

## Subsequent rounds

1. Execute the selected evidence action in the simulator.
2. Admit the new observation/evidence.
3. Update provenance and deterministic constraints.
4. Re-score only affected world/evidence relationships when possible.
5. Reject worlds that violate hard facts.
6. Ask the generator to repair or replace worlds invalidated by the new evidence.
7. Attack the current leaders.
8. Measure whether any material alternative remains missing.
9. Select the next evidence action.
10. Snapshot state.

## Stop conditions

The initial environment stops when any of the following occurs:

- the configured round budget is exhausted;
- no evidence actions remain;
- all surviving worlds make identical predictions for all remaining actions;
- the hidden environment exposes an explicit terminal reveal;
- the experiment runner requests stop for failure/QC reasons.

`all surviving worlds make identical predictions` means further access cannot separate the current candidate set under the implemented action catalog. It does **not** prove that reality contains no unrepresented alternative.

## Final report contract

The report must contain:

- leading supported world(s), without forcing a singleton;
- all surviving materially distinct alternatives;
- rejected worlds and the decisive reason for rejection;
- unresolved actor/motive/source questions;
- evidence counted as source-dependent;
- key assumptions;
- evidence actions taken and why;
- evidence that would still discriminate remaining worlds;
- generation-coverage warning when the true simulator mechanism was not represented during evaluation;
- cost, latency, model/version, and evaluator provenance.
