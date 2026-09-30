defmodule LatentInvestigator.WorldTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.World

  test "execution signature ignores narrative wording but preserves causal structure" do
    a = World.from_candidate(%{client_id: "a", summary: "one", mechanism_family: "m", actor_roles: [], actor_knowledge: [], causal_links: [], source_hypotheses: [], assumptions: ["x"], predictions: ["y"], falsifiers: []})
    b = World.from_candidate(%{client_id: "b", summary: "different prose", mechanism_family: "m", actor_roles: [], actor_knowledge: [], causal_links: [], source_hypotheses: [], assumptions: ["x"], predictions: ["y"], falsifiers: []})
    c = %{b | assumptions: ["x", "z"]}

    assert World.signature(a) == World.signature(b)
    refute World.signature(a) == World.signature(c)
  end
end

defmodule LatentInvestigator.WorldIdCollisionTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Investigation, World}

  test "different worlds that reuse a client id never overwrite prior state" do
    base = %{client_id: "same", summary: "one", mechanism_family: "m1", actor_roles: [], actor_knowledge: [], causal_links: [], source_hypotheses: [], assumptions: [], predictions: ["p1"], falsifiers: []}
    other = %{base | summary: "two", mechanism_family: "m2", predictions: ["p2"]}
    inv = Investigation.new() |> Investigation.add_worlds([World.from_candidate(base), World.from_candidate(other)])
    assert map_size(inv.worlds) == 2
    assert Map.has_key?(inv.worlds, "same")
    assert Enum.any?(inv.worlds, fn {id, world} -> id != "same" and world.metadata[:submitted_id_collision] == "same" end)
  end
end
