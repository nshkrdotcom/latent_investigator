defmodule LatentInvestigator.Runner do
  @moduledoc "Executes the structured investigation loop against a configured simulator."

  alias LatentInvestigator.{
    Acquisition,
    Aggregator,
    Evaluator,
    Investigation,
    LocalJudgments,
    Report,
    Search
  }

  alias LatentInvestigator.Generator.Context, as: GeneratorContext
  alias LatentInvestigator.Evaluator.Context, as: EvaluatorContext

  defmodule Result do
    @moduledoc false
    defstruct [:environment, :investigation, :report, :manifest, :artifacts]
    @type t :: %__MODULE__{}
  end

  def run(opts) when is_list(opts) do
    simulator = Keyword.get(opts, :simulator, LatentInvestigator.Simulator.StrategicNetwork)
    seed = Keyword.get(opts, :seed, 1)

    profile =
      Keyword.get(
        opts,
        :profile,
        Application.get_env(:latent_investigator, :default_profile, :smoke)
      )

    case_class =
      Keyword.get(
        opts,
        :case_class,
        Application.get_env(:latent_investigator, :default_case_class, :transition)
      )

    access =
      Keyword.get(
        opts,
        :access_regime,
        Application.get_env(:latent_investigator, :default_access_regime, :public)
      )

    with {:ok, env} <- simulator.new(seed, profile, case_class, access),
         {:ok, result} <- run_environment(env, Keyword.put(opts, :simulator, simulator)) do
      {:ok, result}
    end
  end

  def run_environment(env, opts) do
    simulator = Keyword.fetch!(opts, :simulator)
    generator = Keyword.fetch!(opts, :generator)
    %GeneratorContext{} = generator_context = Keyword.fetch!(opts, :generator_context)
    evaluator = Keyword.fetch!(opts, :evaluator)
    %EvaluatorContext{} = evaluator_context = Keyword.fetch!(opts, :evaluator_context)

    actions = simulator.available_actions(env, nil)

    inv =
      Investigation.new(
        actors: simulator.public_actors(env),
        observations: simulator.initial_observations(env),
        provenance: simulator.known_provenance(env),
        actions: actions,
        config: run_config(opts)
      )

    with {:ok, initial_worlds} <- generator.initial(generator_context, inv, generator_opts(opts)),
         inv <- Investigation.add_worlds(inv, initial_worlds),
         {:ok, env, inv} <-
           loop(
             env,
             inv,
             simulator,
             generator,
             generator_context,
             evaluator,
             evaluator_context,
             opts
           ),
         report <- final_report(env, inv, simulator),
         manifest <- manifest(env, inv, opts),
         evaluation <- evaluation_artifact(env, simulator),
         {:ok, artifacts} <- maybe_persist(manifest, inv, report, evaluation, opts) do
      {:ok,
       %Result{
         environment: env,
         investigation: inv,
         report: report,
         manifest: manifest,
         artifacts: artifacts
       }}
    end
  end

  defp loop(env, inv, simulator, generator, generator_context, evaluator, evaluator_context, opts) do
    with {:ok, inv} <- evaluate(inv, evaluator, evaluator_context, opts),
         {:ok, inv} <-
           maybe_attack(inv, generator, generator_context, evaluator, evaluator_context, opts) do
      actions = simulator.available_actions(env, inv)

      cond do
        stop?(inv, actions, simulator, opts) ->
          {:ok, env, inv}

        true ->
          case Acquisition.choose(inv, actions, simulator) do
            :none ->
              {:ok, env, inv}

            {:ok, selected} ->
              with {:ok, next_env, new_observations} <- simulator.execute(env, selected.action) do
                next_round = inv.round + 1
                new_observations = Enum.map(new_observations, &%{&1 | round: next_round})

                next_inv =
                  inv
                  |> Investigation.record_action(
                    selected.action.id,
                    %{utility: selected.utility, separated_pairs: selected.separated_pairs},
                    Enum.map(new_observations, & &1.id)
                  )
                  |> Investigation.advance_round()
                  |> Investigation.admit_observations(new_observations)
                  |> Map.put(:provenance, simulator.known_provenance(next_env))
                  |> Investigation.put_actions(simulator.available_actions(next_env, inv))

                with {:ok, repairs} <- maybe_repair(next_inv, generator, generator_context, opts) do
                  next_inv = Investigation.add_worlds(next_inv, repairs)

                  loop(
                    next_env,
                    next_inv,
                    simulator,
                    generator,
                    generator_context,
                    evaluator,
                    evaluator_context,
                    opts
                  )
                end
              end
          end
      end
    end
  end

  defp evaluate(inv, evaluator, context, opts) do
    requests = LocalJudgments.compatibility_requests(inv)

    with {:ok, judgments} <- Evaluator.judge_many(evaluator, context, requests) do
      inv = Investigation.add_judgments(inv, judgments)

      agg_opts = [
        max_alive_worlds:
          Keyword.get(
            opts,
            :max_alive_worlds,
            Application.get_env(:latent_investigator, :max_alive_worlds, 32)
          ),
        fit_gap_limit:
          Keyword.get(
            opts,
            :fit_gap_limit,
            Application.get_env(:latent_investigator, :fit_gap_limit, 0.75)
          ),
        protected_diversity_slots:
          Keyword.get(
            opts,
            :protected_diversity_slots,
            Application.get_env(:latent_investigator, :protected_diversity_slots, 4)
          )
      ]

      {:ok, Aggregator.run(inv, agg_opts)}
    end
  end

  defp maybe_attack(inv, generator, generator_context, evaluator, evaluator_context, opts) do
    count =
      Keyword.get(
        opts,
        :attack_worlds_per_round,
        Application.get_env(:latent_investigator, :attack_worlds_per_round, 2)
      )

    leaders = inv |> Investigation.alive_worlds() |> Search.rank() |> Enum.take(count)

    if leaders == [] or Keyword.get(opts, :disable_attack, false) do
      {:ok, inv}
    else
      case generator.attack(generator_context, inv, leaders, generator_opts(opts)) do
        {:ok, []} ->
          {:ok, inv}

        {:ok, alternatives} ->
          inv
          |> Investigation.add_worlds(alternatives)
          |> evaluate(evaluator, evaluator_context, opts)

        {:error, reason} ->
          {:error, {:attack_failed, reason}}
      end
    end
  end

  defp maybe_repair(inv, generator, generator_context, opts) do
    rejected =
      inv.worlds
      |> Map.values()
      |> Enum.filter(&(&1.status == :rejected and &1.generation[:round] == inv.round - 1))

    if rejected == [] or Keyword.get(opts, :disable_repair, false) do
      {:ok, []}
    else
      generator.repair(generator_context, inv, rejected, generator_opts(opts))
    end
  end

  defp stop?(inv, actions, simulator, opts) do
    budget =
      Keyword.get(
        opts,
        :round_budget,
        Application.get_env(:latent_investigator, :round_budget, 3)
      )

    inv.round >= budget or actions == [] or
      indistinguishable_on_remaining_actions?(inv, actions, simulator)
  end

  defp indistinguishable_on_remaining_actions?(inv, actions, simulator) do
    worlds = Investigation.alive_worlds(inv)

    worlds != [] and
      Enum.all?(actions, fn action ->
        worlds
        |> Enum.map(&simulator.predict(&1, action, []))
        |> Enum.filter(&match?({:ok, _}, &1))
        |> Enum.uniq()
        |> length() <= 1
      end)
  end

  defp final_report(env, inv, simulator) do
    truth = simulator.hidden_truth(env)

    coverage =
      Enum.any?(Map.values(inv.worlds), fn world ->
        simulator.match_world(truth, world).compatible
      end)

    Report.build(inv, simulator.task_targets(env), generation_coverage_warning: not coverage)
  end

  defp manifest(env, inv, opts) do
    contract = %{
      app_version: LatentInvestigator.version(),
      prompt_version: "1",
      schema_version: "1",
      aggregation_version: "ordinal_provenance_v1",
      judgment_batch_size: Keyword.get(opts, :judgment_batch_size, 1),
      k_initial: Keyword.get(opts, :k_initial, 8),
      round_budget:
        Keyword.get(
          opts,
          :round_budget,
          Application.get_env(:latent_investigator, :round_budget, 3)
        ),
      max_alive_worlds:
        Keyword.get(
          opts,
          :max_alive_worlds,
          Application.get_env(:latent_investigator, :max_alive_worlds, 32)
        )
    }

    %{
      version: LatentInvestigator.version(),
      investigation_id: inv.id,
      seed: Map.get(env, :seed),
      model_replicate: Keyword.get(opts, :model_replicate, 0),
      arm: Keyword.get(opts, :arm, :structured),
      profile: Map.get(env, :profile),
      case_class: Map.get(env, :case_class),
      access_regime: Map.get(env, :access_regime),
      round_budget: contract.round_budget,
      frozen_contract: contract,
      frozen_contract_hash: LatentInvestigator.ID.stable("contract", contract),
      started_at: Keyword.get(opts, :started_at, LatentInvestigator.Util.now_iso8601())
    }
  end

  defp evaluation_artifact(env, simulator) do
    %{
      hidden_truth: simulator.hidden_truth(env),
      evaluation_targets: simulator.evaluation_targets(env),
      seed: Map.get(env, :seed),
      profile: Map.get(env, :profile),
      case_class: Map.get(env, :case_class),
      access_regime: Map.get(env, :access_regime)
    }
  end

  defp maybe_persist(manifest, inv, report, evaluation, opts) do
    if Keyword.get(opts, :persist, false) do
      LatentInvestigator.ArtifactStore.persist(manifest, inv, report,
        root: Keyword.get(opts, :artifact_root),
        evaluation: evaluation
      )
    else
      {:ok, nil}
    end
  end

  defp generator_opts(opts), do: [k_initial: Keyword.get(opts, :k_initial, 8)]

  defp run_config(opts) do
    opts
    |> Keyword.take([
      :round_budget,
      :max_alive_worlds,
      :fit_gap_limit,
      :protected_diversity_slots,
      :k_initial
    ])
    |> Map.new()
  end
end
