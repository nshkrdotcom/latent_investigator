# Source Baseline

Implementation was written against the sealed snapshots supplied with the task:

- System One SDK snapshot containing `system_one_sdk` version 0.6.0;
- Inference snapshot containing `inference` version 0.5.0.

Source APIs inspected before implementation included:

- `SystemOneSDK.Client` and `SystemOneSDK.new_client/1`;
- `SystemOneSDK.evaluate/4`;
- typed `SystemOneSDK.noul/2`, `choice/3`, and `score/3` constructors;
- `SystemOneSDK.Test` deterministic client/stubs;
- `Inference.Client.new!/1`;
- `Inference.complete/3`;
- `Inference.Response` structured `object`, usage, provider/model, and trace fields;
- strict `{:json_schema, ...}` response format;
- `Inference.Adapters.Mock` for deterministic tests.

No APIs were intentionally invented. Because this environment has no Elixir runtime, the receiving agent must compile against the exact local dependency checkout and repair any source-snapshot drift.
