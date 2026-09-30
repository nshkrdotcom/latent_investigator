defmodule LatentInvestigator.Experiment.Gate0 do
  @moduledoc "Early monolithic baseline scale reconnaissance before full structured investment."
  alias LatentInvestigator.Baseline.Monolithic
  alias LatentInvestigator.Experiment.Common
  alias LatentInvestigator.Simulator.StrategicNetwork

  def run(opts \\ []) do
    client = Keyword.get(opts, :client) || LatentInvestigator.Config.inference_client!(:frontier)
    seeds = Keyword.get(opts, :seeds, [1, 2, 3])
    profiles = Keyword.get(opts, :profiles, [:smoke, :small, :medium, :large])
    case_class = Keyword.get(opts, :case_class, :transition)
    access = Keyword.get(opts, :access_regime, :public)

    results =
      for profile <- profiles, seed <- seeds do
        {:ok, env} = StrategicNetwork.new(seed, profile, case_class, access)
        {:ok, b0a} = Monolithic.run(env, StrategicNetwork, client, :single, opts)
        {:ok, b0b} = Monolithic.run(env, StrategicNetwork, client, :iterative, opts)
        %{profile: profile, seed: seed, b0a: Common.score_baseline(b0a, StrategicNetwork), b0b: Common.score_baseline(b0b, StrategicNetwork)}
      end

    {:ok, %{gate: :baseline_reconnaissance, results: results}}
  end
end
