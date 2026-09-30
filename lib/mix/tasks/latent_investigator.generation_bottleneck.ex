defmodule Mix.Tasks.LatentInvestigator.GenerationBottleneck do
  use Mix.Task
  @shortdoc "Run the candidate-generation oracle ablation"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    case LatentInvestigator.Experiment.GenerationBottleneck.run() do
      {:ok, result} -> IO.puts(LatentInvestigator.JSON.encode!(result))
      {:error, reason} -> Mix.raise("generation bottleneck experiment failed: #{inspect(reason)}")
    end
  end
end
