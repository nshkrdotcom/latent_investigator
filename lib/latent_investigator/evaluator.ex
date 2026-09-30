defmodule LatentInvestigator.Evaluator do
  @moduledoc "Project-local local-judgment provider boundary."
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}
  alias LatentInvestigator.Judgment

  @callback judge(Context.t(), JudgmentRequest.t()) :: {:ok, Judgment.t()} | {:error, term()}
  @callback judge_many(Context.t(), [JudgmentRequest.t()]) :: {:ok, [Judgment.t()]} | {:error, term()}
  @optional_callbacks judge_many: 2

  def judge_many(module, %Context{} = context, requests) do
    if function_exported?(module, :judge_many, 2) do
      module.judge_many(context, requests)
    else
      Enum.reduce_while(requests, {:ok, []}, fn request, {:ok, acc} ->
        case module.judge(context, request) do
          {:ok, judgment} -> {:cont, {:ok, [judgment | acc]}}
          {:error, reason} -> {:halt, {:error, %{request_id: request.id, reason: reason}}}
        end
      end)
      |> case do
        {:ok, values} -> {:ok, Enum.reverse(values)}
        error -> error
      end
    end
  end
end
