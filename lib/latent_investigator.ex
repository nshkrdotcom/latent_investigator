defmodule LatentInvestigator do
  @moduledoc """
  Persistent competing-world investigation for partial and strategically generated evidence.

  Models propose or judge. The Elixir core owns authoritative investigation state.
  """

  alias LatentInvestigator.{Investigation, Runner}

  @version "0.1.0"
  def version, do: @version

  @doc "Run one structured investigation with explicit simulator/generator/evaluator configuration."
  @spec run(keyword()) :: {:ok, Runner.Result.t()} | {:error, term()}
  def run(opts), do: Runner.run(opts)

  @doc "Build an empty investigation state for deterministic/core tests and custom hosts."
  def new_investigation(attrs \\ []), do: Investigation.new(attrs)
end
