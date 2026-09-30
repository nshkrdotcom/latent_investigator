# Runtime QC

This environment has no `elixir`, `mix`, or `erl` executable. The following are therefore **NOT_RUN**:

- dependency resolution;
- formatter;
- compilation;
- warnings-as-errors;
- ExUnit;
- Dialyzer/Credo (not declared as dependencies);
- deterministic smoke task;
- artifact replay task;
- live Inference provider calls;
- live System One/Jev calls;
- baseline reconnaissance;
- Gate 1;
- Gate 2;
- cost/token measurement from real providers.

Source-only checks performed before delivery are recorded in `SOURCE_QC_REPORT.md`.

The receiving agent should treat compile errors and failing tests as implementation defects to repair against the frozen v1.1 contract, not as a reason to redesign the experiment unless execution exposes a genuine conceptual contradiction.
