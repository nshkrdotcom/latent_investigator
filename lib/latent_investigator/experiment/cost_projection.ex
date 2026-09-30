defmodule LatentInvestigator.Experiment.CostProjection do
  @moduledoc "Pre-run call-volume projection. Pricing is optional and never guessed."

  alias LatentInvestigator.Simulator.StrategicNetwork

  def project(opts \\ []) do
    profiles = Keyword.get(opts, :profiles, [:medium])
    k = Keyword.get(opts, :k_initial, 8)

    rounds =
      Keyword.get(
        opts,
        :round_budget,
        Application.get_env(:latent_investigator, :round_budget, 3)
      ) + 1

    batch_size = Keyword.get(opts, :judgment_batch_size, 16)
    seeds = length(Keyword.get(opts, :seeds, Enum.to_list(1..10)))
    replicates = Keyword.get(opts, :replicates, 3)

    classes =
      length(Keyword.get(opts, :case_classes, [:resolvable, :non_identifiable, :transition]))

    rows =
      Enum.map(profiles, fn profile ->
        shape = StrategicNetwork.profile_shape(profile)
        judgments_per_round = shape.observations * k
        judgment_calls_per_round = Integer.ceil_div(judgments_per_round, max(batch_size, 1))
        structured_calls = rounds * judgment_calls_per_round + 1 + max(rounds - 1, 0)
        runs = seeds * replicates * classes

        %{
          profile: profile,
          actors: shape.actors,
          observations: shape.observations,
          candidate_worlds: k,
          estimated_local_judgments_per_run: rounds * judgments_per_round,
          estimated_structured_model_calls_per_run: structured_calls,
          qualification_runs: runs,
          estimated_structured_calls_total: structured_calls * runs
        }
      end)

    %{
      assumptions: %{
        rounds: rounds,
        judgment_batch_size: batch_size,
        k_initial: k,
        excludes_repair_and_dynamic_world_growth: true
      },
      profiles: rows
    }
  end
end
