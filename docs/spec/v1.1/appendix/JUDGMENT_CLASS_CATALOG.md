# Judgment Class Catalog

This catalog freezes the initial semantic classes so Gate 2 compares like with like.

## semantic_entailment

**Question:** Does the supplied observation semantically support/express the supplied proposition?

Preferred output: binary probability or categorical yes/no plus confidence; mapped to ordinal only when used in world fit.

## source_dependence

**Question:** Given the visible text/metadata, how likely is it that two observations share an underlying source rather than being independent?

Preferred output: ordered categorical domain.

## actor_behavior_plausibility

**Question:** Given only the stated actor knowledge, capabilities, goals, and context, how plausible is the described behavior?

Preferred output: five-level ordinal.

## observation_compatibility

**Question:** If world W were true, how compatible is evidence unit E with that world?

Preferred output: five-level ordinal.

## mechanism_plausibility

**Question:** Given the explicit constraints, how plausible is mechanism M as a generator of event E?

Preferred output: five-level ordinal.

## textual_contradiction

**Question:** Does observation E semantically contradict claim C?

Preferred output: binary/ordinal.

## Excluded from model judgment

Chronology, exact provenance already revealed, explicit actor access, ID equality, action availability, and other deterministic facts.
