# Source Baseline

This specification was written against the two sealed Repomix snapshots supplied with the request.

## System One SDK snapshot

- snapshot SHA-256: `acf283c1d254293cf1fe634f037c0f861bab298f3d524b4db9c5d37bd639fd2d`
- package app: `:system_one_sdk`
- package version in snapshot: `0.6.0`
- Elixir requirement in package: `~> 1.18`
- public facade: `SystemOneSDK`
- strict semantic entry point: `SystemOneSDK.evaluate/4`
- question primitives: Noul, Choice, Score
- strict constructors: `SystemOneSDK.noul/2`, `choice/3`, `score/3`
- prepared question sets: `SystemOneSDK.prepare!/1`
- answer access: `SystemOneSDK.Response.fetch!/2`
- stable response metadata includes model, request ID, usage, retries, elapsed time, and prepared fingerprint

The SDK describes Jev as the first public System One model and defaults hosted TypeSafe use to `jev-latest`, but confirmatory experiment runs must record the concrete returned model/version rather than treating a moving alias as immutable.

## Inference snapshot

- snapshot SHA-256: `a7e30d9b4dccc106923367725d4d9dd4ad01a57105b4684e1becd03e6cc84ee9`
- package app: `:inference`
- package version in snapshot: `0.5.0`
- Elixir requirement in package: `~> 1.18`
- public facade: `Inference`
- client: `Inference.Client`
- completion: `Inference.complete/3`
- capability query: `Inference.capabilities/1`
- response carries text, optional structured object, usage, provider-reported cost, finish reason, metadata, and trace
- strict response-format union includes named JSON Schema output
- only the mock adapter is fully self-contained; live adapters require consuming-app provider dependencies

## Local dependency convention

Per the user instruction, the new project specifies:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

The implementation agent must verify those checkouts resolve the expected Mix applications before coding. The Repomix snapshots themselves are monorepo/workspace-shaped; the requested local path convention is therefore an environment contract rather than a fact inferred from snapshot directory layout.

## No invented API rule

If implementation finds that a source API differs from this baseline, inspect the actual local dependency source and update the integration module accordingly. Do not create imaginary wrapper calls to preserve this document verbatim.
