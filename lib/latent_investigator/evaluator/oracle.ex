defmodule LatentInvestigator.Evaluator.Oracle do
  @moduledoc "Diagnostic evaluator backed by hidden simulator truth or hand-authored fixtures."
  @behaviour LatentInvestigator.Evaluator

  alias LatentInvestigator.{Judgment, Util}
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}

  @impl true
  def judge(%Context{oracle_fun: fun} = context, %JudgmentRequest{} = request) when is_function(fun, 1) do
    started = System.monotonic_time(:microsecond)
    case fun.(request) do
      {:ok, result} -> {:ok, build(context, request, result, started)}
      result when is_map(result) -> {:ok, build(context, request, result, started)}
      {:error, _} = error -> error
      other -> {:error, {:invalid_oracle_result, other}}
    end
  end

  def judge(_context, _request), do: {:error, :oracle_fun_required}

  defp build(context, request, result, started) do
    value = Util.get(result, :value)
    Judgment.new(%{
      id: request.id,
      request_id: request.id,
      kind: request.kind,
      subject_ref: Util.get(request.metadata, :evidence_unit_id),
      observation_id: request.observation_id,
      world_id: request.world_id,
      value: value,
      ordinal_weight: Util.get(result, :ordinal_weight, Judgment.compatibility_weight(value)),
      provider: context.provider || :oracle,
      model: context.model || "oracle",
      provider_confidence: Util.get(result, :confidence, 1.0),
      distribution: Util.get(result, :distribution),
      latency_ms: (System.monotonic_time(:microsecond) - started) / 1000,
      usage: nil,
      cost: 0.0,
      round: request.round,
      metadata: %{oracle: true}
    })
  end
end
