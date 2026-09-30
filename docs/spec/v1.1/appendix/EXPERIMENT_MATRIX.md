# Experiment Matrix

## Early baseline reconnaissance

| Arm | State | Compute | Purpose |
|---|---|---|---|
| B0a monolithic | prompt/transcript only | ordinary strong baseline | cheap headroom check |
| B0b iterative monolithic | prompt/transcript only | matched/repeated frontier budget | control for extra inference compute |

Run these after the simulator exists and before the full structured core.

## Gate 0

| Generator | Local evaluator | Purpose |
|---|---|---|
| oracle | oracle | deterministic architecture ceiling |
| frontier | oracle | isolate generation |
| oracle | frontier | isolate local semantic judgment |

## Gate 1

| Arm | Generator/attacker | Local evaluator | State model |
|---|---|---|---|
| B0a monolithic | frontier | internal | prompt/transcript only |
| B0b compute-matched monolithic | frontier iterative | internal | prompt/transcript only |
| B1 structured | frontier | frontier | deterministic external core |

Each qualification seed is repeated across model replicate IDs. Gate 1 includes resolvable, non-identifiable, and transition cases.

## Gate 2 frozen workload

| Arm | Generator | Local evaluator |
|---|---|---|
| oracle-local | frozen frontier candidates | oracle |
| frontier-local | frozen frontier candidates | frontier model |
| cheap-local | frozen frontier candidates | cheap general model |
| system-one-local | frozen frontier candidates | System One/Jev |

## Gate 2 end-to-end

Same evaluator arms, but each may affect ranking/pruning inside the otherwise frozen architecture.

## Diagnostic generation comparison

Normal generator versus generation-oracle truth injection under the same local evaluator.
