defmodule LatentInvestigator.ConstraintTest do
  use ExUnit.Case, async: true
  import LatentInvestigator.TestFixtures
  alias LatentInvestigator.{Constraint, Observation}

  test "authenticated provenance hard-rejects an incompatible source hypothesis" do
    auth = Observation.new(%{id: "auth", surface: "audit", authenticated_source: "a1", metadata: %{authenticates_observation_id: "obs1"}})
    inv = investigation(observations: [observation("obs1"), auth], worlds: [world("wrong", "a2")])
    [wrong] = Map.values(inv.worlds)
    rejected = Constraint.apply(inv, wrong)
    assert rejected.status == :rejected
    assert Enum.any?(rejected.hard_failures, &(&1.code == :authenticated_source_conflict))
  end
end

defmodule LatentInvestigator.ConstraintChronologyTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Constraint, Investigation, Observation, Actor, World}

  test "a source cannot use knowledge acquired after the observation" do
    actor = Actor.new(%{id: "a1", capabilities: [:publish]})
    obs = Observation.new(%{id: "o1", surface: "event", timestamp: "2026-01-01T00:01:00Z"})
    world = World.from_candidate(%{client_id: "w1", summary: "late knowledge", mechanism_family: "m", actor_roles: [], actor_knowledge: [%{actor_id: "a1", fact_id: "f", status: "knows", by_time: "2026-01-01T00:02:00Z"}], causal_links: [], source_hypotheses: [%{observation_id: "o1", source_actor_id: "a1", mechanism: "published", claimed_source_status: "x"}], assumptions: [], predictions: [], falsifiers: []})
    inv = Investigation.new(actors: [actor], observations: [obs]) |> Investigation.add_worlds([world])
    [failure] = Constraint.failures(inv, world)
    assert failure.code == :knowledge_after_observation
  end
end
