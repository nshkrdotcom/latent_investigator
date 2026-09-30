# Strategic Network Simulator

The `LatentInvestigator.Simulator.StrategicNetwork` module provides a benchmark environment for evaluating causal investigation under adversarial, misleading, and noisy conditions.

## Simulation Profiles

The simulator scales across four distinct profiles to evaluate both cheap smoke runs and publication-scale investigations:

| Profile | Actors | Observations | Typical Evidence Actions | Target Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `:smoke` | 5 | ~20 | 3 - 5 | Quick local debugging & zero-network tests |
| `:small` | 20 | ~150 | 15 - 25 | Baseline reconnaissance & preliminary sweeps |
| `:medium`| 40 | ~400 | 40 - 60 | Primary Gate 1 & Gate 2 qualification scale |
| `:large` | 80 | ~1000 | 100+ | Large-scale stress testing |

## Diagnostic Case Classes

To evaluate investigator performance rigorously, the simulator generates scenarios belonging to three fundamental case classes:

### 1. `:resolvable`
- The scenario contains both public authenticated sources and public authenticated mechanism witnesses.
- A competent investigator can conclusively resolve the true causal world and reject false alternatives from available or easily acquired evidence.

### 2. `:transition`
- Initial evidence is deceptive, ambiguous, or points strongly toward a plausible decoy hypothesis.
- As the investigation proceeds and deeper evidence actions are taken, authenticated witnesses emerge that distinguish the true actor and mechanism.
- Evaluates **transition recovery** (metric P3): whether an agent can overturn an initial misleading consensus.

### 3. `:non_identifiable`
- Competing hypotheses (e.g., benign protective motive vs. hostile espionage motive) produce observationally equivalent public traces.
- Even exhaustive search cannot break symmetry without restricted operator access.
- Tests whether the investigator correctly reports fundamental ambiguity rather than hallucinating certainty.

## Access Regimes

Observations and evidence actions are partitioned into access levels:
- `:public`: Open-source feeds, unauthenticated rumors, public statements.
- `:limited`: Privileged telemetry, internal logs, verified channel communications.
- `:operator`: Restricted forensic snapshots, cryptographic key records, physical device access.
- `:oracle`: Ground truth view (used exclusively by test evaluation harnesses).

## Strategic Communication & Noise

The simulator introduces realistic friction:
- **Copied Evidence**: Multiple observations reciting identical claims through downstream re-transmission.
- **Spoofed Sources**: Messages falsely claiming to originate from high-reputation actors.
- **Uncertain Provenance**: Observations whose transmission chains are ambiguous or partially obscured.
- **Heterogeneous Actor Capabilities**: Actors with distinct resources, credentials, and network reach.
