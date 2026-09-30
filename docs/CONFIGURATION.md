# Configuration

## Path dependencies

`mix.exs` uses exactly:

```elixir
{:system_one_sdk, path: "../system_one_sdk"},
{:inference, path: "../inference"}
```

The receiving workspace must make those paths resolve to package roots. If the local source repositories are monorepos, reconcile the filesystem layout or use local package-root copies/symlinks; do not silently rewrite the requested dependency contract during QC.

## Inference clients

This project intentionally does not add Gemini/Claude/Codex/etc. provider SDKs. A host configures `Inference.Client` values and injects them:

```elixir
Application.put_env(:latent_investigator, :frontier_inference_client, frontier_client)
Application.put_env(:latent_investigator, :cheap_inference_client, cheap_client)
```

`LatentInvestigator.Config.inference_client!/1` validates only that the value is an `Inference.Client`. Provider capability/preflight errors remain dependency/provider errors.

## System One

Inject an explicit client when desired:

```elixir
Application.put_env(:latent_investigator, :system_one_client, client)
```

Otherwise `Config.system_one_client!/0` calls `SystemOneSDK.new_client/0`, which relies on System One's own configured/default provider.

## Research knobs

Defaults live in `config/config.exs`. Gate runners accept keyword overrides so a frozen run can record its actual scale/batching/resource settings.
