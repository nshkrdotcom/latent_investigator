# Future Extension — External Environments

Do not integrate these before the initial strategic-network experiment works.

The following resources were verified as existing at docset creation time and represent different external-validity directions.

## RCAEval

RCAEval is an open-source root-cause-analysis benchmark for microservice systems. Its current repository describes nine datasets organized into three suites, 735 failure cases across Online Boutique, Sock Shop, and Train Ticket, multiple telemetry modalities, annotated root causes, and reproducible baselines.

Potential use: test causal-world maintenance over real technical telemetry after the investigator core works.

## Apache/MITRE Caldera

Caldera is an open-source automated adversary-emulation platform based on ATT&CK-style adversary behavior. MITRE contributed it to the Apache Incubator in 2026.

Potential use: run controlled strategic/adversarial processes in a real system while preserving known adversary actions.

## NTSB accident dockets

The NTSB public docket search exposes factual reports and evidence used in probable-cause investigations, with many dockets containing preliminary reports, factual reports, attachments, and final reports.

Potential use: time-slice a real investigation and compare what the system could justify at different evidence stages. Final probable cause is an adjudicated investigation conclusion, not omniscient ground truth.

## Avalon-NLU

The Avalon-NLU dataset contains long-horizon game dialogue with ground-truth player roles, game state, deception strategy labels, persuasion labels, and some player-belief annotations.

Potential use: strategic communication / hidden knowledge component testing. It is not a novelty source by itself because this area is already actively studied.

## Principle

The same investigator core should operate across future environments. If each environment requires a new reasoning architecture, the project has become a set of domain-specific demos rather than a general investigator.
