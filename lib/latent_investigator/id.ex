defmodule LatentInvestigator.ID do
  @moduledoc false

  @spec stable(String.t() | atom(), term()) :: String.t()
  def stable(prefix, material) do
    digest =
      material
      |> :erlang.term_to_binary([:deterministic])
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)
      |> binary_part(0, 16)

    "#{prefix}_#{digest}"
  end

  @spec new(String.t() | atom()) :: String.t()
  def new(prefix) do
    stable(prefix, {System.system_time(:nanosecond), System.unique_integer([:positive, :monotonic]), self()})
  end
end
