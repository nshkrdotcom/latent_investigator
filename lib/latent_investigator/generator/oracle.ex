defmodule LatentInvestigator.Generator.Oracle do
  @moduledoc "Deterministic candidate provider for smoke tests and generation-oracle ablations."
  @behaviour LatentInvestigator.Generator
  alias LatentInvestigator.Generator.Context

  @impl true
  def initial(%Context{config: config}, _inv, _opts), do: {:ok, Map.get(config, :worlds, [])}
  @impl true
  def attack(%Context{config: config}, _inv, _worlds, _opts),
    do: {:ok, Map.get(config, :attack_worlds, [])}

  @impl true
  def repair(%Context{config: config}, _inv, _worlds, _opts),
    do: {:ok, Map.get(config, :repair_worlds, [])}
end
