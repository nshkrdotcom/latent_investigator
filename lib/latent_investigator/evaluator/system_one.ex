defmodule LatentInvestigator.Evaluator.SystemOne do
  @moduledoc "Bounded local judgments through SystemOneSDK; never a global world scorer."
  @behaviour LatentInvestigator.Evaluator

  alias LatentInvestigator.{Judgment, Util}
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}
  alias SystemOneSDK.{ChoiceAnswer, NoulAnswer, ScoreAnswer}

  @compat_levels [
    {:strongly_against, "Materially difficult to reconcile with the proposed world."},
    {:against, "Weighs against the proposed world."},
    {:neutral, "Compatible but not materially discriminating."},
    {:supports, "More expected in the proposed world than salient alternatives."},
    {:strongly_supports, "Strongly characteristic of the proposed world."}
  ]

  @source_choices [
    {:same_source, "Almost certainly the same underlying information source."},
    {:likely_related, "Likely dependent or derived."},
    {:unclear, "Insufficient evidence about dependence."},
    {:likely_independent, "Likely independent."},
    {:independent, "Strong evidence of independent origin."}
  ]

  @impl true
  def judge(
        %Context{client: %SystemOneSDK.Client{} = client} = context,
        %JudgmentRequest{} = request
      ) do
    question = question(request)
    opts = if is_binary(context.model), do: [model: context.model], else: []
    state_bytes = byte_size(LatentInvestigator.JSON.encode!(request.state))

    with {:ok, response} <-
           SystemOneSDK.evaluate(client, request.state, %{request.id => question}, opts),
         {:ok, answer} <- Map.fetch(response.answers, request.id),
         {:ok, normalized} <- normalize_answer(request, answer) do
      {:ok,
       Judgment.new(
         Map.merge(normalized, %{
           id: request.id,
           request_id: response.request_id || request.id,
           kind: request.kind,
           subject_ref: Util.get(request.metadata, :evidence_unit_id),
           observation_id: request.observation_id,
           world_id: request.world_id,
           provider: :system_one,
           model: response.model,
           latency_ms: response.elapsed_ms,
           usage: usage_map(response.usage),
           cost: nil,
           round: request.round,
           metadata: %{
             prepared_fingerprint: response.prepared_fingerprint,
             retries: response.retries,
             state_bytes: state_bytes,
             transport_call_id: request.id
           }
         })
       )}
    else
      :error -> {:error, :system_one_answer_missing}
      {:error, _} = error -> error
      other -> {:error, {:invalid_system_one_response, other}}
    end
  end

  defp question(%JudgmentRequest{kind: kind})
       when kind in [
              :observation_compatibility,
              :actor_behavior_plausibility,
              :mechanism_plausibility
            ] do
    SystemOneSDK.score(
      "Judge the bounded state using the fixed ordered rubric.",
      Enum.map(@compat_levels, fn {label, description} -> {Atom.to_string(label), description} end)
    )
  end

  defp question(%JudgmentRequest{kind: :source_dependence}) do
    SystemOneSDK.choice(
      "Judge whether the two evidence surfaces derive from the same underlying information source.",
      @source_choices
    )
  end

  defp question(%JudgmentRequest{kind: kind})
       when kind in [:semantic_entailment, :textual_contradiction] do
    SystemOneSDK.noul("Is the queried semantic relation true in the bounded state?",
      true: "Yes",
      false: "No"
    )
  end

  defp normalize_answer(_request, %ScoreAnswer{} = answer) do
    raw_label =
      answer.label ||
        Enum.at(
          [:strongly_against, :against, :neutral, :supports, :strongly_supports],
          round(answer.score || 2)
        )

    label =
      Enum.find(Enum.map(@compat_levels, &elem(&1, 0)), &(to_string(&1) == to_string(raw_label)))

    {:ok,
     %{
       value: label,
       ordinal_weight: Judgment.compatibility_weight(label),
       provider_confidence: answer.confidence,
       distribution: answer.probabilities
     }}
  end

  defp normalize_answer(_request, %ChoiceAnswer{} = answer),
    do:
      {:ok,
       %{
         value: answer.choice,
         ordinal_weight: nil,
         provider_confidence: answer.confidence,
         distribution: answer.probabilities
       }}

  defp normalize_answer(_request, %NoulAnswer{} = answer) do
    value = if answer.noul >= 0.5, do: :yes, else: :no

    {:ok,
     %{
       value: value,
       ordinal_weight: nil,
       provider_confidence: max(answer.noul, 1.0 - answer.noul),
       distribution: %{true: answer.noul, false: 1.0 - answer.noul}
     }}
  end

  defp normalize_answer(_request, other), do: {:error, {:unexpected_answer_type, other}}

  defp usage_map(nil), do: nil

  defp usage_map(usage),
    do: %{input_tokens: usage.input_tokens, output_tokens: usage.output_tokens}
end
