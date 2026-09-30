defmodule LatentInvestigator.Util do
  @moduledoc false

  def get(attrs, key, default \\ nil)
  def get(attrs, key, default) when is_map(attrs), do: Map.get(attrs, key, Map.get(attrs, to_string(key), default))
  def get(attrs, key, default) when is_list(attrs), do: Keyword.get(attrs, key, default)
  def get(_, _, default), do: default

  def list(nil), do: []
  def list(value) when is_list(value), do: value
  def list(value), do: [value]

  def map(nil), do: %{}
  def map(value) when is_map(value), do: value
  def map(value) when is_list(value), do: Map.new(value)
  def map(_), do: %{}

  def string(value) when is_binary(value), do: value
  def string(value) when is_atom(value), do: Atom.to_string(value)
  def string(value), do: to_string(value)

  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

  def sorted_map_list(map) when is_map(map) do
    map |> Enum.sort_by(fn {k, _} -> inspect(k) end)
  end

  def canonical(term) when is_map(term) and not is_struct(term) do
    term
    |> sorted_map_list()
    |> Enum.map(fn {k, v} -> {canonical(k), canonical(v)} end)
  end

  def canonical(%_{} = struct), do: struct |> Map.from_struct() |> canonical()
  def canonical(term) when is_list(term), do: Enum.map(term, &canonical/1)
  def canonical(term) when is_tuple(term), do: term |> Tuple.to_list() |> canonical()
  def canonical(term), do: term

  def now_iso8601, do: DateTime.utc_now() |> DateTime.truncate(:millisecond) |> DateTime.to_iso8601()

  def parse_time(nil), do: :error
  def parse_time(%DateTime{} = value), do: {:ok, value}
  def parse_time(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, _offset} -> {:ok, dt}
      _ -> :error
    end
  end
  def parse_time(_), do: :error

  def truncate(text, max) when is_binary(text) and is_integer(max) and max > 0 do
    if String.length(text) <= max, do: text, else: String.slice(text, 0, max) <> "…"
  end
  def truncate(value, _), do: value
end
