# Candidate Generation Bottleneck

The architecture cannot evaluate a world it never generated.

## Questions

1. How often does the frontier generator include a world compatible with hidden truth in the initial K candidates?
2. Does attack/reframing recover omitted mechanisms over later rounds?
3. Does increasing K improve recall or merely increase redundant/false-fit worlds?
4. How much does generation-oracle injection improve final performance?

## Protocol

For each simulator seed:

1. freeze initial observations;
2. run normal initial generation at K values such as 4, 8, 16;
3. canonicalize/deduplicate;
4. score hidden-world structural coverage;
5. run one and then multiple attack/reframe rounds;
6. repeat with the generation oracle.

## Hidden-world coverage

Because the simulator truth is structured, coverage should be evaluated against execution-relevant factors rather than narrative similarity.

At minimum compare:

- mechanism family;
- responsible/causal actor assignment where material;
- key information-flow path;
- source/provenance mechanism for the designed strategic observations.

A candidate may count as partial coverage when only some factors match. Define the matcher in code before using results.

## Why this is separate from local evaluation

If actual generation misses the true mechanism while a generation-oracle run succeeds, improving Jev calibration is solving the wrong problem.
