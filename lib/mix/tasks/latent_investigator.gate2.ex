defmodule Mix.Tasks.LatentInvestigator.Gate2 do
  @moduledoc "Run Gate 2 evaluator substitution diagnostic. Requires frontier, cheap and System One clients."
  @shortdoc "Run Gate 2"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")
    case LatentInvestigator.Experiment.Gate2.run() do
      {:ok, result} -> Mix.shell().info(inspect(result, pretty: true, limit: :infinity))
      {:error, reason} -> Mix.raise("Gate 2 failed: #{inspect(reason)}")
    end
  end
end
