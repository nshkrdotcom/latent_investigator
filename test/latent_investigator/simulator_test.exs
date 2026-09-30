defmodule LatentInvestigator.SimulatorTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.Simulator.StrategicNetwork

  test "same seed/config yields deterministic hidden world and visible observations" do
    {:ok, a} = StrategicNetwork.new(42, :small, :transition, :public)
    {:ok, b} = StrategicNetwork.new(42, :small, :transition, :public)
    assert a.true_world == b.true_world
    assert StrategicNetwork.initial_observations(a) == StrategicNetwork.initial_observations(b)
  end

  test "public actors do not expose simulator goals or known facts" do
    {:ok, env} = StrategicNetwork.new(3, :smoke, :transition, :public)
    assert Enum.all?(StrategicNetwork.public_actors(env), &(&1.goals == [] and &1.known_facts == []))
  end

  test "operator-only actions are absent from public action catalog" do
    {:ok, env} = StrategicNetwork.new(3, :smoke, :transition, :public)
    ids = StrategicNetwork.available_actions(env, nil) |> Enum.map(& &1.id)
    refute "act_channel_log" in ids
    refute "act_knowledge" in ids
  end

  test "non-identifiable public case keeps the motive target unresolved" do
    {:ok, env} = StrategicNetwork.new(1, :smoke, :non_identifiable, :public)
    motive = StrategicNetwork.evaluation_targets(env) |> Enum.find(&(&1.id == "target_motive"))
    assert motive.expected_status == :unresolved
  end
end

defmodule LatentInvestigator.SimulatorResolutionClassTest do
  use ExUnit.Case, async: true

  alias LatentInvestigator.{Constraint, Investigation}
  alias LatentInvestigator.Simulator.StrategicNetwork

  test "resolvable cases contain public hard evidence for source and mechanism" do
    {:ok, env} = StrategicNetwork.new(1, :smoke, :resolvable, :public)
    inv = Investigation.new(actors: StrategicNetwork.public_actors(env), observations: StrategicNetwork.initial_observations(env), provenance: StrategicNetwork.known_provenance(env))
    [truth | alternatives] = StrategicNetwork.oracle_candidates(env)

    assert Constraint.failures(inv, truth) == []
    assert Enum.any?(alternatives, fn world -> Enum.any?(Constraint.failures(inv, world), &(&1.code in [:authenticated_source_conflict, :authenticated_mechanism_conflict])) end)
    assert Enum.all?(StrategicNetwork.evaluation_targets(env), &(&1.expected_status == :supported))
  end

  test "transition source authentication does not manufacture mechanism identification" do
    {:ok, env} = StrategicNetwork.new(1, :smoke, :transition, :public)
    same_source_alt = Enum.find(StrategicNetwork.oracle_candidates(env), &(&1.mechanism_family == "ordinary_upstream_coordination"))
    refute is_nil(same_source_alt)

    auth = Enum.find(StrategicNetwork.available_actions(env, nil), &(&1.id == "act_auth_anchor"))
    {:ok, env2, observations} = StrategicNetwork.execute(env, auth)
    inv = Investigation.new(actors: StrategicNetwork.public_actors(env2), observations: StrategicNetwork.initial_observations(env2) ++ observations, provenance: StrategicNetwork.known_provenance(env2))

    assert Constraint.failures(inv, same_source_alt) == []
    statuses = Map.new(StrategicNetwork.evaluation_targets(env2), &{&1.id, &1.expected_status})
    assert statuses["target_source"] == :supported
    assert statuses["target_mechanism"] == :unresolved
  end

  test "non-identifiable motive remains unresolved at public access" do
    {:ok, env} = StrategicNetwork.new(1, :smoke, :non_identifiable, :public)
    target = Enum.find(StrategicNetwork.evaluation_targets(env), &(&1.id == "target_motive"))
    assert target.expected_status == :unresolved
  end
end
