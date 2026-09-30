# Ordinal Aggregation & Redundancy Dominance

Latent Investigator replaces uncalibrated probabilistic multiplying with deterministic, provenance-aware ordinal aggregation and diversity-preserving search.

## Five-Level Ordinal Aggregator (`LatentInvestigator.Aggregator`)

Standard Bayesian aggregators multiply model confidence outputs, compounding calibration errors and unmodeled dependencies. Latent Investigator evaluates compatibility along an explicit five-level ordinal scale:

1. **Refuted (`:refuted`)**: Violated a hard constraint or contradicted by authenticated evidence. The world is eliminated from active consideration.
2. **Contested (`:contested`)**: Plagued by substantial unexplained anomalies or direct contradictions with plausible witnesses.
3. **Plausible (`:plausible`)**: Partially consistent with observations, but requires unverified auxiliary assumptions or lacks direct confirmation.
4. **Strong (`:strong`)**: Strongly supported by multiple independent evidence lines with minimal unexplained residue.
5. **Established (`:established`)**: Uniquely corroborated by authenticated sources and mechanisms, with all competing alternatives refuted or dominated.

### Why Avoid Pseudo-Bayesian Multiplication?
LLMs are notoriously uncalibrated: an output of `0.99` confidence often reflects prompt formatting or training artifacts rather than true Bayesian likelihood. In Latent Investigator:
- Model confidence is treated purely as a local diagnostic readout.
- Global world scoring is computed via deterministic rules that weigh independent provenance clusters, penalty for ungrounded claims, and explanatory coverage.

---

## Redundancy Dominance

A pervasive failure mode in complex hypothesis generation is the creation of sprawling "epicycle" worlds: hypotheses that evade refutation by tacking on speculative, untestable auxiliary assumptions (e.g., "Actor X did it, but used an unknown intermediary with fabricated credentials and zero trace").

Latent Investigator implements **Redundancy Dominance**:
- If World $W_1$ and World $W_2$ explain the same verified evidence, but $W_2$ introduces auxiliary assumptions that make no material testable predictions, $W_1$ strictly dominates $W_2$.
- Dominated worlds are pruned to conserve beam bandwidth.
- Note: If additional structure makes material, discriminating predictions that can be verified with accessible evidence actions, it is **not** penalized.

---

## Diversity-Preserving Search & Pruning (`LatentInvestigator.Search`)

To avoid beam collapse where all top $k$ candidates become minor variations of the same hypothesis:
- Candidate worlds are clustered by causal core (actor, mechanism, and primary motive).
- Beam pruning preserves the highest-scoring candidate from each distinct cluster before allocating remaining slots.
- The investigation maintains a diverse frontier of mutually exclusive explanations.

---

## Acquisition via Pair Separation (`LatentInvestigator.Acquisition`)

When deciding which costly evidence action to execute next:
- The investigator computes **pair-separation scores** across the top competing hypotheses.
- It prioritizes actions whose expected observations have the greatest power to rule out at least one top contender while confirming another.
