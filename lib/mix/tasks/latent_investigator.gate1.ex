defmodule Mix.Tasks.LatentInvestigator.Gate1 do
  @moduledoc "Run Gate 1 B0a/B0b/B1 qualification. Requires a configured frontier Inference.Client."
  @shortdoc "Run Gate 1"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")
    case LatentInvestigator.Experiment.Gate1.run() do
      {:ok, result} -> Mix.shell().info(inspect(result.summary, pretty: true))
      {:error, reason} -> Mix.raise("Gate 1 failed: #{inspect(reason)}")
    end
  end
end
