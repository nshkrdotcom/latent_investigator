defmodule LatentInvestigator.ArtifactStore do
  @moduledoc "Filesystem run artifacts: manifest, immutable event log, final report and state snapshot."
  alias LatentInvestigator.{JSON, Investigation}

  def persist(manifest, %Investigation{} = inv, report, opts \\ []) do
    root =
      Keyword.get(opts, :root) ||
        Application.get_env(:latent_investigator, :artifact_root, "tmp/runs")

    run_dir =
      Path.join(root, manifest[:investigation_id] || manifest["investigation_id"] || "run")

    File.mkdir_p!(run_dir)

    write_json(Path.join(run_dir, "manifest.json"), manifest)
    write_json(Path.join(run_dir, "report.json"), report)
    write_json(Path.join(run_dir, "state.json"), state_snapshot(inv))
    write_jsonl(Path.join(run_dir, "events.jsonl"), inv.history)

    case Keyword.get(opts, :evaluation) do
      nil -> :ok
      evaluation -> write_json(Path.join(run_dir, "evaluation.json"), evaluation)
    end

    hashes = file_hashes(run_dir)
    write_json(Path.join(run_dir, "hashes.json"), hashes)
    {:ok, %{run_dir: Path.expand(run_dir), hashes: hashes}}
  rescue
    error -> {:error, {:artifact_persist_failed, error}}
  end

  defp state_snapshot(inv) do
    %{
      id: inv.id,
      round: inv.round,
      observations: inv.observations,
      actors: inv.actors,
      worlds: inv.worlds,
      judgments: inv.judgments,
      provenance: inv.provenance,
      actions: inv.actions,
      config: inv.config
    }
  end

  defp write_json(path, value), do: File.write!(path, JSON.encode!(value) <> "\n")

  defp write_jsonl(path, values),
    do: File.write!(path, Enum.map_join(values, "", &(JSON.encode!(&1) <> "\n")))

  defp file_hashes(run_dir) do
    ["manifest.json", "report.json", "state.json", "events.jsonl", "evaluation.json"]
    |> Enum.filter(&File.exists?(Path.join(run_dir, &1)))
    |> Map.new(fn name -> {name, sha256(Path.join(run_dir, name))} end)
  end

  defp sha256(path),
    do: path |> File.read!() |> then(&:crypto.hash(:sha256, &1)) |> Base.encode16(case: :lower)
end
