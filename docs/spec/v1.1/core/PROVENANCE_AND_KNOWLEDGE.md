# Provenance and Actor Knowledge

The original motivating problem depends heavily on two things monolithic reasoning tends to blur: whether observations are independent and what each actor could have known when acting.

## Provenance graph

The core maintains a directed graph from source events to surface observations.

Known graph operations are deterministic:

- collapse exact copies into one evidence unit;
- expose descendants of a source;
- mark uncertain source relationships;
- record authentication state;
- record spoofing hypotheses separately from authenticated identity.

The simulator maintains a hidden complete graph. The investigator sees only the subgraph justified by revealed evidence.

## Actor knowledge timeline

For each actor, the investigator may maintain proposed knowledge facts:

```text
actor A knew fact X no later than t
actor B could access source S during interval [t1, t2]
actor C is not known to possess X
```

These are world-specific hypotheses unless authenticated evidence makes them global facts.

## Deterministic chronology rule

If a world asserts that actor A used fact X to generate observation M at time `t_m`, and authenticated evidence proves A could not have known X until `t_x > t_m`, the world receives a hard contradiction.

Do not ask a model to decide arithmetic chronology when timestamps are explicit.

## Strategic source uncertainty

A surface message can be:

- genuine and correctly attributed;
- genuine but relayed;
- deliberately mimicking another actor;
- ordinary background content;
- strategically seeded so the channel amplifies it;
- independently generated coincidence inside the synthetic environment.

The world must represent the causal source hypothesis separately from the surface claimed source.

## Why this matters experimentally

The environment will contain designed cases where:

- three reports share one hidden source;
- two actors independently make similar claims;
- one actor mimics another;
- benevolent concealment and hostile concealment predict the same observable behavior;
- later provenance evidence separates worlds that previously tied.
