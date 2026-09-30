defmodule Mix.Tasks.LatentInvestigator.Baseline do
  @moduledoc "Run early monolithic baseline reconnaissance. Requires a configured frontier Inference.Client."
  @shortdoc "Run baseline reconnaissance"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    {:ok, result} = LatentInvestigator.Experiment.Gate0.run()
    Mix.shell().info(inspect(result, pretty: true, limit: :infinity))
  end
end
