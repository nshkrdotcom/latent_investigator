# Agent Instructions

1. Read `docs/CONTINUATION_HANDOFF.md` first for the latest stopping point and immediate next steps, then read `HANDOFF.md`, `docs/IMPLEMENTATION_STATUS.md`, and `docs/spec/v1.1/AGENT_START_HERE.md` before editing.
2. Treat `docs/spec/v1.1/` as the implementation contract. Do not broaden the research program while doing runtime QC.
3. The deterministic Elixir core owns global epistemic state. Do not move provenance, hard constraints, global scoring, or replay state into prompts.
4. Model confidence/distributions are local diagnostic outputs. Do not multiply them into global likelihoods without a new execution-derived research decision.
5. Do not reveal simulator hidden truth or expected labels to normal model arms.
6. Preserve the currently authorized dependency setup: nested sibling System One package root, Hex Inference 0.5.1, and ASM/Codex bridge dependencies. The user explicitly authorized these changes; do not revert to the original two sibling paths.
7. First local task is compile/test/repair. Do not advance the experiment design because a stylistic alternative looks cleaner.
8. Record exact commands and results in the handoff/QC report. Mark unavailable live checks `NOT_RUN`.
