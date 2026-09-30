defmodule LatentInvestigator.TargetTest do
  use ExUnit.Case, async: true
  import LatentInvestigator.TestFixtures
  alias LatentInvestigator.Target

  test "mixed surviving worlds force unresolved rather than unique resolution" do
    a = world("a", "a1")
    b = world("b", "a2")
    target = %{query: %{kind: :source_actor, observation_id: "obs1", actor_id: "a1"}}
    assert Target.resolve([a, b], target) == :unresolved
    assert Target.resolve([a], target) == :supported
    assert Target.resolve([b], target) == :rejected
  end
end
