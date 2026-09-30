defmodule LatentInvestigator.Evaluator.Inference do
  @moduledoc "Bounded structured local judgments through the provider-neutral Inference API."
  @behaviour LatentInvestigator.Evaluator

  alias LatentInvestigator.{ID, Judgment, Prompt, Schema, Util}
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}

  @impl true
  def judge(%Context{client: %Inference.Client{} = client} = context, %JudgmentRequest{} = request) do
    started = System.monotonic_time(:microsecond)
    schema = Schema.local_judgment(request.kind)
    name = "latent_investigator_#{request.kind}"

    with {:ok, response} <- Inference.complete(client, Prompt.local_judgment(request), model_opts(context, name, schema)),
         object when is_map(object) <- response.object,
         {:ok, value} <- normalize_value(request.kind, Util.get(object, :value)) do
      latency = (System.monotonic_time(:microsecond) - started) / 1000
      transport_id = request.id

      {:ok,
       Judgment.new(%{
         id: request.id,
         request_id: request.id,
         kind: request.kind,
         subject_ref: Util.get(request.metadata, :evidence_unit_id),
         observation_id: request.observation_id,
         world_id: request.world_id,
         value: value,
         ordinal_weight: Judgment.compatibility_weight(value),
         provider: response.provider || context.provider || :inference,
         model: response.model || context.model,
         provider_confidence: Util.get(object, :confidence),
         distribution: nil,
         latency_ms: latency,
         usage: response.usage,
         cost: response.cost,
         round: request.round,
         metadata: %{
           rationale: Util.truncate(Util.get(object, :rationale, ""), 500),
           response_id: response.id,
           transport_call_id: transport_id,
           finish_reason: response.finish_reason,
           state_bytes: byte_size(LatentInvestigator.JSON.encode!(request.state))
         }
       })}
    else
      nil -> {:error, :structured_object_missing}
      {:error, _} = error -> error
      other -> {:error, {:invalid_inference_judgment, other}}
    end
  end

  @impl true
  def judge_many(%Context{} = context, requests) when is_list(requests) do
    batch_size = context.config |> Util.get(:batch_size, 1) |> normalize_batch_size()

    if batch_size <= 1 do
      sequential(context, requests)
    else
      requests
      |> Enum.group_by(fn request -> {request.kind, Util.get(request.metadata, :evidence_unit_id)} end)
      |> Enum.sort_by(fn {key, _} -> inspect(key) end)
      |> Enum.reduce_while({:ok, []}, fn {_key, group}, {:ok, acc} ->
        result =
          group
          |> Enum.sort_by(& &1.id)
          |> Enum.chunk_every(batch_size)
          |> Enum.reduce_while({:ok, []}, fn chunk, {:ok, chunk_acc} ->
            case judge_batch(context, chunk) do
              {:ok, values} -> {:cont, {:ok, chunk_acc ++ values}}
              {:error, reason} -> {:halt, {:error, reason}}
            end
          end)

        case result do
          {:ok, values} -> {:cont, {:ok, acc ++ values}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end
  end

  defp judge_batch(%Context{client: %Inference.Client{} = client} = context, [%JudgmentRequest{} = first | _] = requests) do
    started = System.monotonic_time(:microsecond)
    batch_id = ID.stable("batch", Enum.map(requests, & &1.id))
    schema = Schema.local_judgment_batch(first.kind)
    name = "latent_investigator_#{first.kind}_batch"

    with {:ok, response} <- Inference.complete(client, Prompt.local_judgment_batch(requests), model_opts(context, name, schema)),
         object when is_map(object) <- response.object,
         results when is_list(results) <- Util.get(object, :results),
         {:ok, indexed} <- index_results(results, requests) do
      latency = (System.monotonic_time(:microsecond) - started) / 1000
      transport_id = batch_id

      requests
      |> Enum.with_index()
      |> Enum.reduce_while({:ok, []}, fn {request, index}, {:ok, acc} ->
        result = Map.fetch!(indexed, request.id)

        case normalize_value(request.kind, Util.get(result, :value)) do
          {:ok, value} ->
            judgment =
              Judgment.new(%{
                id: request.id,
                request_id: request.id,
                batch_id: batch_id,
                batch_position: index,
                kind: request.kind,
                subject_ref: Util.get(request.metadata, :evidence_unit_id),
                observation_id: request.observation_id,
                world_id: request.world_id,
                value: value,
                ordinal_weight: Judgment.compatibility_weight(value),
                provider: response.provider || context.provider || :inference,
                model: response.model || context.model,
                provider_confidence: Util.get(result, :confidence),
                distribution: nil,
                latency_ms: latency,
                usage: response.usage,
                cost: response.cost,
                round: request.round,
                metadata: %{
                  rationale: Util.truncate(Util.get(result, :rationale, ""), 500),
                  response_id: response.id,
                  transport_call_id: transport_id,
                  finish_reason: response.finish_reason,
                  batch_size: length(requests),
                  state_bytes: byte_size(LatentInvestigator.JSON.encode!(request.state))
                }
              })

            {:cont, {:ok, acc ++ [judgment]}}

          {:error, reason} ->
            {:halt, {:error, {:invalid_batch_value, request.id, reason}}}
        end
      end)
    else
      nil -> {:error, :structured_object_missing}
      {:error, _} = error -> error
      other -> {:error, {:invalid_inference_batch, batch_id, other}}
    end
  end

  defp index_results(results, requests) do
    expected = MapSet.new(requests, & &1.id)

    normalized =
      Enum.reduce_while(results, {:ok, %{}}, fn result, {:ok, acc} ->
        id = Util.get(result, :request_id)

        cond do
          not is_binary(id) -> {:halt, {:error, {:missing_request_id, result}}}
          Map.has_key?(acc, id) -> {:halt, {:error, {:duplicate_request_id, id}}}
          true -> {:cont, {:ok, Map.put(acc, id, result)}}
        end
      end)

    with {:ok, indexed} <- normalized do
      actual = MapSet.new(Map.keys(indexed))

      if actual == expected do
        {:ok, indexed}
      else
        {:error,
         {:batch_request_mismatch,
          %{missing: MapSet.difference(expected, actual) |> MapSet.to_list(), unexpected: MapSet.difference(actual, expected) |> MapSet.to_list()}}}
      end
    end
  end

  defp sequential(context, requests) do
    Enum.reduce_while(requests, {:ok, []}, fn request, {:ok, acc} ->
      case judge(context, request) do
        {:ok, judgment} -> {:cont, {:ok, acc ++ [judgment]}}
        {:error, reason} -> {:halt, {:error, %{request_id: request.id, reason: reason}}}
      end
    end)
  end

  defp model_opts(context, name, schema) do
    opts = [response_format: {:json_schema, %{name: name, schema: schema, strict: true}}]
    if is_binary(context.model), do: Keyword.put(opts, :model, context.model), else: opts
  end

  defp normalize_batch_size(value) when is_integer(value) and value > 0, do: value
  defp normalize_batch_size(_), do: 1

  defp normalize_value(kind, value) do
    allowed =
      case kind do
        :source_dependence -> ~w(same_source likely_related unclear likely_independent independent)
        k when k in [:semantic_entailment, :textual_contradiction] -> ~w(yes no unclear)
        _ -> ~w(strongly_against against neutral supports strongly_supports)
      end

    text = if is_atom(value), do: Atom.to_string(value), else: value
    if text in allowed, do: {:ok, String.to_existing_atom(text)}, else: {:error, {:invalid_value, value}}
  rescue
    ArgumentError -> {:error, {:invalid_value, value}}
  end
end
