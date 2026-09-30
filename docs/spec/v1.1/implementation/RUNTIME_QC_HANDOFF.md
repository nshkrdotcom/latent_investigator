# Runtime QC Handoff Template

Use this after implementation phases or experiment runs.

## Environment

- repository commit:
- Elixir:
- Erlang/OTP:
- OS:
- SystemOneSDK source/version:
- Inference source/version:
- provider/model identities:

## Checks

| Check | Status | Command / evidence |
|---|---|---|
| format | NOT_RUN | |
| compile warnings-as-errors | NOT_RUN | |
| unit tests | NOT_RUN | |
| deterministic simulator replay | NOT_RUN | |
| hidden-truth leakage tests | NOT_RUN | |
| Inference mock integration | NOT_RUN | |
| live frontier generator | NOT_RUN | |
| live frontier evaluator | NOT_RUN | |
| live System One evaluator | NOT_RUN | |
| Gate 1 smoke | NOT_RUN | |
| Gate 1 qualification | NOT_RUN | |
| Gate 2 frozen workload | NOT_RUN | |

## Failures / repairs

Record concrete failures and exact source changes. Do not mark unavailable provider checks as passed.

## Next eligible work

State the next phase from `IMPLEMENTATION_SEQUENCE.md`. Do not advance past a failed dependency gate without recording the decision.
