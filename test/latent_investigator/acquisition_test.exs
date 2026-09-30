defmodule LatentInvestigator.AcquisitionTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Acquisition, Investigation}
  alias LatentInvestigator.Simulator.StrategicNetwork

  test "chooses an available action that separates surviving simulator-compatible worlds" do
    {:ok, env} = StrategicNetwork.new(1, :smoke, :transition, :public)
    inv = Investigation.new(actors: StrategicNetwork.public_actors(env), observations: StrategicNetwork.initial_observations(env), provenance: StrategicNetwork.known_provenance(env))
      |> Investigation.add_worlds(StrategicNetwork.oracle_candidates(env))
    actions = StrategicNetwork.available_actions(env, inv)
    {:ok, selected} = Acquisition.choose(inv, actions, StrategicNetwork)
    assert selected.separated_pairs > 0
    assert selected.action.id in Enum.map(actions, & &1.id)
  end
end
