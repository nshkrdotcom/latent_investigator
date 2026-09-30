defmodule LatentInvestigator.JSON do
  @moduledoc false

  def encode!(term) do
    ensure_jason!()
    Jason.encode!(safe(term))
  end

  def decode!(binary) when is_binary(binary) do
    ensure_jason!()
    Jason.decode!(binary)
  end

  def safe(nil), do: nil
  def safe(true), do: true
  def safe(false), do: false
  def safe(value) when is_binary(value) or is_number(value), do: value
  def safe(value) when is_atom(value), do: Atom.to_string(value)
  def safe(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def safe(%_{} = value), do: value |> Map.from_struct() |> safe()
  def safe(value) when is_map(value), do: Map.new(value, fn {k, v} -> {safe_key(k), safe(v)} end)
  def safe(value) when is_list(value), do: Enum.map(value, &safe/1)
  def safe(value) when is_tuple(value), do: value |> Tuple.to_list() |> safe()
  def safe(value), do: inspect(value)

  defp safe_key(key) when is_binary(key), do: key
  defp safe_key(key) when is_atom(key), do: Atom.to_string(key)
  defp safe_key(key), do: to_string(key)

  defp ensure_jason! do
    unless Code.ensure_loaded?(Jason) do
      raise "Jason is unavailable; current SystemOneSDK 0.6.0 is expected to provide it transitively"
    end
  end
end
