defmodule Mix.Tasks.LatentInvestigator.Gate1 do
  @moduledoc "Run Gate 1 B0a/B0b/B1 qualification. Requires a configured frontier Inference.Client."
  @shortdoc "Run Gate 1"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    {:ok, result} = LatentInvestigator.Experiment.Gate1.run()
    Mix.shell().info(inspect(result.summary, pretty: true))
  end
end
