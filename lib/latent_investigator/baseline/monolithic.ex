defmodule LatentInvestigator.Baseline.Monolithic do
  @moduledoc "Strong plain/iterative frontier-model baseline with no authoritative structured core."

  alias LatentInvestigator.{Prompt, Schema, Util, World}

  defmodule Result do
    @moduledoc false
    defstruct [:environment, :report, worlds: [], responses: [], usage: %{}, history: []]
  end

  def run(env, simulator, %Inference.Client{} = client, mode, opts \\ [])
      when mode in [:single, :iterative] do
    loop(
      env,
      simulator,
      client,
      mode,
      opts,
      nil,
      [],
      [],
      [],
      Keyword.get(opts, :compute_budget_tokens)
    )
  end

  defp loop(
         env,
         simulator,
         client,
         mode,
         opts,
         prior,
         responses,
         history,
         revealed,
         remaining_budget
       ) do
    round = Map.get(env, :round, 0)
    actions = simulator.available_actions(env, nil)
    state = public_state(env, simulator, actions, prior, revealed)

    if mode == :iterative and is_integer(remaining_budget) and remaining_budget <= 0 and
         not is_nil(prior) do
      finish(env, prior, responses, history)
    else
      round_opts =
        if mode == :iterative and is_integer(remaining_budget),
          do: Keyword.put(opts, :compute_budget_tokens, remaining_budget),
          else: opts

      with {:ok, output, stage_responses} <- analyze(client, state, mode, round_opts) do
        responses = responses ++ stage_responses

        remaining_budget =
          if is_integer(remaining_budget),
            do: remaining_budget - total_tokens(stage_responses),
            else: remaining_budget

        history = history ++ [%{round: round, output: output}]

        budget =
          Keyword.get(
            opts,
            :round_budget,
            Application.get_env(:latent_investigator, :round_budget, 3)
          )

        action_id = Util.get(output, :next_action_id)

        cond do
          round >= budget ->
            finish(env, output, responses, history)

          is_nil(action_id) ->
            finish(env, output, responses, history)

          true ->
            case Enum.find(actions, &(&1.id == action_id)) do
              nil ->
                finish(env, Map.put(output, "invalid_action_id", action_id), responses, history)

              action ->
                case simulator.execute(env, action) do
                  {:ok, next_env, new_obs} ->
                    loop(
                      next_env,
                      simulator,
                      client,
                      mode,
                      opts,
                      output,
                      responses,
                      history,
                      revealed ++ new_obs,
                      remaining_budget
                    )

                  {:error, _} ->
                    finish(env, output, responses, history)
                end
            end
        end
      end
    end
  end

  defp analyze(client, state, :single, opts) do
    with {:ok, response} <- complete(client, Prompt.baseline(state, :analyze), opts),
         object when is_map(object) <- response.object do
      {:ok, object, [response]}
    else
      nil -> {:error, :structured_object_missing}
      error -> error
    end
  end

  defp analyze(client, state, :iterative, opts) do
    budget = Keyword.get(opts, :compute_budget_tokens)
    max_calls = Keyword.get(opts, :compute_match_max_calls, 64)
    stages = [:analyze, :attack, :revise]
    iterative_calls(client, state, opts, stages, budget, max_calls, 0, nil, [])
  end

  defp iterative_calls(
         _client,
         _state,
         _opts,
         _stages,
         _budget,
         max_calls,
         calls,
         prior,
         responses
       )
       when calls >= max_calls and not is_nil(prior),
       do: {:ok, prior, responses}

  defp iterative_calls(client, state, opts, stages, budget, max_calls, calls, prior, responses) do
    used = total_tokens(responses)
    stop_for_budget = is_integer(budget) and budget > 0 and used >= budget and not is_nil(prior)
    stop_without_budget = is_nil(budget) and calls >= length(stages) and not is_nil(prior)

    if stop_for_budget or stop_without_budget do
      {:ok, prior, responses}
    else
      stage = Enum.at(stages, rem(calls, length(stages)))
      stage_state = if prior, do: Map.put(state, :previous_analysis, prior), else: state

      case complete(client, Prompt.baseline(stage_state, stage), opts) do
        {:ok, response} when is_map(response.object) ->
          iterative_calls(
            client,
            state,
            opts,
            stages,
            budget,
            max_calls,
            calls + 1,
            response.object,
            responses ++ [response]
          )

        {:ok, _response} ->
          {:error, :structured_object_missing}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp complete(client, prompt, opts) do
    model = Keyword.get(opts, :model)

    call_opts = [
      response_format:
        {:json_schema,
         %{name: "latent_investigator_baseline", schema: Schema.baseline_round(), strict: true}}
    ]

    call_opts = if is_binary(model), do: Keyword.put(call_opts, :model, model), else: call_opts
    Inference.complete(client, prompt, call_opts)
  end

  defp public_state(env, simulator, actions, prior, revealed) do
    %{
      access_regime: Map.get(env, :access_regime),
      round: Map.get(env, :round),
      actors: simulator.public_actors(env),
      observations: simulator.initial_observations(env) ++ revealed,
      targets: simulator.task_targets(env),
      available_actions: actions,
      previous_analysis: prior
    }
  end

  defp finish(env, output, responses, history) do
    worlds = output |> Util.get(:worlds, []) |> Enum.map(&World.from_candidate/1)

    target_statuses =
      output
      |> Util.get(:target_statuses, [])
      |> Map.new(fn item -> {Util.get(item, :target_id), Util.get(item, :status)} end)

    report = %{
      worlds: output |> Util.get(:worlds, []),
      target_statuses: target_statuses,
      rejected_explanations: Util.get(output, :rejected_explanations, []),
      provenance_concerns: Util.get(output, :provenance_concerns, []),
      unresolved_questions: Util.get(output, :unresolved_questions, []),
      non_identifiable_claims: Util.get(output, :non_identifiable_claims, []),
      conclusion: Util.get(output, :conclusion, ""),
      next_action_id: Util.get(output, :next_action_id)
    }

    {:ok,
     %Result{
       environment: env,
       report: report,
       worlds: worlds,
       responses: responses,
       usage: usage(responses),
       history: history
     }}
  end

  defp total_tokens(responses),
    do:
      Enum.reduce(responses, 0, fn response, acc ->
        acc + token(response.usage || %{}, :input_tokens) +
          token(response.usage || %{}, :output_tokens)
      end)

  defp usage(responses) do
    Enum.reduce(
      responses,
      %{
        calls: 0,
        input_tokens: 0,
        output_tokens: 0,
        reported_cost: 0.0,
        by_provider: %{},
        by_model: %{}
      },
      fn response, acc ->
        usage = response.usage || %{}
        in_tokens = token(usage, :input_tokens)
        out_tokens = token(usage, :output_tokens)
        cost = if(is_number(response.cost), do: response.cost, else: 0.0)
        provider = response.provider || :unknown
        model = response.model || get_in(response.metadata || %{}, [:model_version]) || :unknown

        %{
          calls: acc.calls + 1,
          input_tokens: acc.input_tokens + in_tokens,
          output_tokens: acc.output_tokens + out_tokens,
          reported_cost: acc.reported_cost + cost,
          by_provider: add_resource(acc.by_provider, provider, in_tokens, out_tokens, cost),
          by_model: add_resource(acc.by_model, model, in_tokens, out_tokens, cost)
        }
      end
    )
  end

  defp add_resource(map, key, input_tokens, output_tokens, cost) do
    current =
      Map.get(map, key, %{calls: 0, input_tokens: 0, output_tokens: 0, reported_cost: 0.0})

    Map.put(map, key, %{
      calls: current.calls + 1,
      input_tokens: current.input_tokens + input_tokens,
      output_tokens: current.output_tokens + output_tokens,
      reported_cost: current.reported_cost + cost
    })
  end

  defp token(map, key), do: Map.get(map, key, Map.get(map, to_string(key), 0)) || 0
end
