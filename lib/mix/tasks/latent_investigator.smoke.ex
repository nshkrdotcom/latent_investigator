defmodule Mix.Tasks.LatentInvestigator.Smoke do
  @moduledoc "Run the pure deterministic strategic-network smoke investigation."
  @shortdoc "Run deterministic latent-investigator smoke"
  use Mix.Task

  @impl true
  def run(args) do
    Mix.Task.run("app.start")
    {opts, _rest, _invalid} = OptionParser.parse(args, switches: [seed: :integer, persist: :boolean])
    seed = Keyword.get(opts, :seed, 1)
    persist = Keyword.get(opts, :persist, false)

    case LatentInvestigator.Experiment.Smoke.run(seed: seed, persist: persist) do
      {:ok, result} ->
        Mix.shell().info("smoke ok investigation=#{result.investigation.id} round=#{result.investigation.round}")
        Mix.shell().info("targets=#{inspect(result.report.target_statuses)}")
        if result.artifacts, do: Mix.shell().info("artifacts=#{result.artifacts.run_dir}")

      {:error, reason} ->
        Mix.raise("latent investigator smoke failed: #{inspect(reason)}")
    end
  end
end
