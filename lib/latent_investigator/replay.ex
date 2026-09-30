defmodule LatentInvestigator.Replay do
  @moduledoc "Loads persisted normalized run artifacts without invoking model providers."
  alias LatentInvestigator.JSON

  def load(run_dir) do
    with {:ok, manifest} <- read_json(Path.join(run_dir, "manifest.json")),
         {:ok, report} <- read_json(Path.join(run_dir, "report.json")),
         {:ok, state} <- read_json(Path.join(run_dir, "state.json")),
         {:ok, events} <- read_jsonl(Path.join(run_dir, "events.jsonl")),
         {:ok, evaluation} <- read_optional_json(Path.join(run_dir, "evaluation.json")) do
      {:ok,
       %{manifest: manifest, report: report, state: state, events: events, evaluation: evaluation}}
    end
  end

  def verify(run_dir) do
    with {:ok, expected} <- read_json(Path.join(run_dir, "hashes.json")) do
      mismatches =
        Enum.reject(expected, fn {name, hash} -> sha256(Path.join(run_dir, name)) == hash end)

      if mismatches == [], do: :ok, else: {:error, {:hash_mismatch, mismatches}}
    end
  end

  defp read_json(path) do
    case File.read(path) do
      {:ok, bytes} -> {:ok, JSON.decode!(bytes)}
      {:error, reason} -> {:error, {path, reason}}
    end
  rescue
    error -> {:error, {path, error}}
  end

  defp read_optional_json(path) do
    if File.exists?(path), do: read_json(path), else: {:ok, nil}
  end

  defp read_jsonl(path) do
    case File.read(path) do
      {:ok, bytes} ->
        {:ok, bytes |> String.split("\n", trim: true) |> Enum.map(&JSON.decode!/1)}

      {:error, reason} ->
        {:error, {path, reason}}
    end
  rescue
    error -> {:error, {path, error}}
  end

  defp sha256(path),
    do: path |> File.read!() |> then(&:crypto.hash(:sha256, &1)) |> Base.encode16(case: :lower)
end
