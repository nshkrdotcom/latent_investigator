# Inference Integration

`Inference` is the provider-neutral completion surface for candidate generation, attack/reframing, monolithic baselines, and the two general-model local evaluators.

## Source-backed client and completion API

The supplied snapshot supports `Inference.Client` plus `Inference.complete/3` and structured response formats.

Conceptually:

```elixir
client = Inference.Client.new!(adapter: adapter_module, provider: provider, model: model)

{:ok, response} =
  Inference.complete(client, prompt_or_messages,
    response_format:
      {:json_schema,
       %{name: "candidate_worlds", schema: schema, strict: true}}
  )
```

Check `Inference.capabilities(client)` before dispatch and require needed structured-output support.

## Structured output is mandatory for machine contracts

Generator, attacker, monolithic baseline report, and Inference-backed local evaluator calls use named JSON Schema output when supported. If the chosen adapter cannot honor the required schema, fail preflight.

## Monolithic baselines

B0a uses the strongest practical single-investigator prompt/transcript loop.

B0b uses the same state boundary but receives repeated analysis/attack/revision calls under a compute budget matched to B1. The Inference integration must record token/call usage so the runner can verify the match instead of assuming it.

## Local-evaluator batching

Inference itself need not expose a special batch API. The project may combine a bounded set of logical judgment requests into one structured completion, for example one evidence unit scored against several candidate worlds.

If used:

- every logical request keeps its own request ID;
- chunk size/order are frozen in qualification config;
- output schema returns one result per request/world;
- batch-vs-individual fixture is run first;
- actual provider tokens/cost are attributed to the batch and apportioned only for diagnostics, not invented as provider facts.

## Response fields

The project may consume normalized object/text, provider/model identity, usage, cost when reported, finish reason, and redacted trace metadata.

Provider-reported cost may be nil. Do not manufacture provider cost. Separate frozen-price estimates are allowed only when labeled estimates.

## Raw response rule

Do not persist raw provider responses by default. Persist normalized objects, usage/cost summaries, and redacted trace metadata.

## Provider selection

The docset does not pin Gemini, ReqLlmNext, ASM, or another provider. Live provider packages remain consuming-application dependencies. Strong and cheap clients are explicit experiment configuration.

## Agent-session adapters

Prefer ordinary model-endpoint semantics for the initial experiment unless the local environment specifically requires an agent-session provider.
