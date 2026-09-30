defmodule LatentInvestigator.Experiment.GenerationBottleneck do
  @moduledoc """
  Candidate-generation oracle ablation.

  The same frozen generated candidate set is evaluated twice. The oracle arm adds
  the hidden true world while leaving local judgment, aggregation, pruning, and
  reporting unchanged. This isolates candidate omission from downstream scoring.
  """

  alias LatentInvestigator.{Config, Investigation, Runner}
  alias LatentInvestigator.Evaluator.Context, as: EvaluatorContext
  alias LatentInvestigator.Generator.Context, as: GeneratorContext
  alias LatentInvestigator.Experiment.Common
  alias LatentInvestigator.Simulator.StrategicNetwork

  def run(opts \\ []) do
    client = Keyword.get(opts, :frontier_client) || Config.inference_client!(:frontier)
    seed = Keyword.get(opts, :seed, 1)
    profile = Keyword.get(opts, :profile, :medium)
    case_class = Keyword.get(opts, :case_class, :transition)
    access = Keyword.get(opts, :access_regime, :public)
    batch_size = Keyword.get(opts, :judgment_batch_size, 16)

    with {:ok, env} <- StrategicNetwork.new(seed, profile, case_class, access),
         base <- base_investigation(env),
         {:ok, generated} <-
           LatentInvestigator.Generator.Inference.initial(
             %GeneratorContext{client: client, provider: :frontier},
             base,
             k_initial: Keyword.get(opts, :k_initial, 8)
           ),
         truth <- oracle_truth(env),
         {:ok, generated_result} <-
           run_frozen(env, generated, client, batch_size, opts, :generated_only),
         {:ok, oracle_result} <-
           run_frozen(
             env,
             dedupe_worlds(generated ++ [truth]),
             client,
             batch_size,
             opts,
             :generation_oracle
           ) do
      generated_score = Common.score_structured(generated_result, StrategicNetwork)
      oracle_score = Common.score_structured(oracle_result, StrategicNetwork)

      {:ok,
       %{
         experiment: :generation_bottleneck,
         seed: seed,
         profile: profile,
         case_class: case_class,
         access_regime: access,
         generated_candidate_count: length(generated),
         generated_contains_truth: generated_contains_truth?(generated, env),
         generated_only: generated_score,
         generation_oracle: oracle_score,
         delta: %{
           final_macro_f1: oracle_score.target.macro_f1 - generated_score.target.macro_f1,
           true_world_retention:
             bool_delta(oracle_score.true_world_retention, generated_score.true_world_retention)
         },
         interpretation:
           "A positive oracle delta isolates candidate omission only within this controlled simulator and frozen downstream pipeline."
       }}
    end
  end

  def inject_true_world(investigation, env) do
    Investigation.add_worlds(investigation, [oracle_truth(env)])
  end

  defp run_frozen(env, worlds, client, batch_size, opts, arm) do
    Runner.run_environment(
      env,
      Keyword.merge(opts,
        simulator: StrategicNetwork,
        generator: LatentInvestigator.Generator.Oracle,
        generator_context: %GeneratorContext{
          provider: :oracle_generation,
          config: %{worlds: worlds}
        },
        evaluator: LatentInvestigator.Evaluator.Inference,
        evaluator_context: %EvaluatorContext{
          client: client,
          provider: :frontier,
          config: %{batch_size: batch_size}
        },
        disable_attack: true,
        disable_repair: true,
        arm: arm
      )
    )
  end

  defp base_investigation(env) do
    Investigation.new(
      actors: StrategicNetwork.public_actors(env),
      observations: StrategicNetwork.initial_observations(env),
      provenance: StrategicNetwork.known_provenance(env),
      actions: StrategicNetwork.available_actions(env, nil)
    )
  end

  defp oracle_truth(env) do
    truth = StrategicNetwork.hidden_truth(env)

    %{
      truth
      | id: truth.id <> "_generation_oracle",
        generation: truth.generation |> Map.put(:mode, :generation_oracle) |> Map.put(:round, 0)
    }
  end

  defp dedupe_worlds(worlds) do
    worlds
    |> Enum.reduce([], fn world, acc ->
      if Enum.any?(acc, &same_material_world?(&1, world)), do: acc, else: acc ++ [world]
    end)
  end

  defp generated_contains_truth?(worlds, env) do
    truth = StrategicNetwork.hidden_truth(env)
    Enum.any?(worlds, &StrategicNetwork.match_world(truth, &1).compatible)
  end

  defp same_material_world?(left, right) do
    left.actor_sources == right.actor_sources and
      left.mechanisms == right.mechanisms and
      left.motives == right.motives and
      left.knowledge == right.knowledge
  end

  defp bool_delta(true, false), do: 1
  defp bool_delta(false, true), do: -1
  defp bool_delta(_, _), do: 0
end
