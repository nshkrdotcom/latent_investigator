defmodule LatentInvestigator.Experiment.Smoke do
  @moduledoc "Pure deterministic smoke path: strategic simulator + oracle generator + oracle local evaluator."

  alias LatentInvestigator.Runner
  alias LatentInvestigator.Evaluator.Context, as: EvaluatorContext
  alias LatentInvestigator.Generator.Context, as: GeneratorContext
  alias LatentInvestigator.Simulator.StrategicNetwork

  def run(opts \\ []) do
    seed = Keyword.get(opts, :seed, 1)
    profile = Keyword.get(opts, :profile, :smoke)
    case_class = Keyword.get(opts, :case_class, :transition)
    access = Keyword.get(opts, :access_regime, :public)

    with {:ok, env} <- StrategicNetwork.new(seed, profile, case_class, access) do
      worlds = StrategicNetwork.oracle_candidates(env)

      Runner.run_environment(env,
        Keyword.merge(opts,
          simulator: StrategicNetwork,
          generator: LatentInvestigator.Generator.Oracle,
          generator_context: %GeneratorContext{provider: :oracle, model: "oracle-generator", config: %{worlds: worlds}},
          evaluator: LatentInvestigator.Evaluator.Oracle,
          evaluator_context: %EvaluatorContext{provider: :oracle, model: "oracle", oracle_fun: &StrategicNetwork.oracle_judgment(env, &1)},
          disable_attack: true,
          disable_repair: true,
          arm: :smoke
        ))
    end
  end
end
