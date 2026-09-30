defmodule Mix.Tasks.LatentInvestigator.Replay do
  @moduledoc "Verify and load a persisted run directory without model calls."
  @shortdoc "Replay normalized run artifacts"
  use Mix.Task

  @impl true
  def run([run_dir]) do
    Mix.Task.run("app.start")
    case LatentInvestigator.Replay.verify(run_dir) do
      :ok -> :ok
      {:error, reason} -> Mix.raise("artifact hash verification failed: #{inspect(reason)}")
    end

    case LatentInvestigator.Replay.load(run_dir) do
      {:ok, replay} -> Mix.shell().info(inspect(replay.report, pretty: true, limit: :infinity))
      {:error, reason} -> Mix.raise("replay failed: #{inspect(reason)}")
    end
  end

  def run(_args), do: Mix.raise("usage: mix latent_investigator.replay RUN_DIR")
end
