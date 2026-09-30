defmodule LatentInvestigator.AggregatorTest do
  use ExUnit.Case, async: true
  import LatentInvestigator.TestFixtures
  alias LatentInvestigator.{Aggregator, Investigation, Provenance}

  test "known duplicate surfaces do not add independent fit" do
    o1 = observation("obs1", provenance_ref: "root")
    o2 = observation("obs2", provenance_ref: "root")
    w = world("w", "a1")
    inv0 = investigation(observations: [o1, o2], worlds: [w])
    [unit] = Aggregator.evidence_units(inv0)
    j = compatibility("j", "w", unit.id, "obs1", 2)
    inv = Investigation.add_judgments(inv0, [j]) |> Aggregator.run()
    assert_in_delta inv.worlds["w"].fit_score, 1.0, 1.0e-9
  end

  test "observationally tied worlds remain tied" do
    w1 = world("w1", "a1")
    w2 = world("w2", "a2")
    inv0 = investigation(worlds: [w1, w2])
    [unit] = Aggregator.evidence_units(inv0)

    inv =
      inv0
      |> Investigation.add_judgments([
        compatibility("j1", "w1", unit.id, "obs1", 1),
        compatibility("j2", "w2", unit.id, "obs1", 1)
      ])
      |> Aggregator.run()

    assert inv.worlds["w1"].fit_score == inv.worlds["w2"].fit_score
  end

  test "unsupported sprawling assumptions are redundancy dominated" do
    simple = world("simple", "a1", assumptions: ["a"], predictions: ["p"])
    big = world("big", "a1", assumptions: ["a", "gratuitous"], predictions: ["p"])
    inv0 = investigation(worlds: [simple, big])
    [unit] = Aggregator.evidence_units(inv0)

    inv =
      inv0
      |> Investigation.add_judgments([
        compatibility("j1", "simple", unit.id, "obs1", 1),
        compatibility("j2", "big", unit.id, "obs1", 1)
      ])
      |> Aggregator.run()

    assert inv.worlds["big"].redundancy_dominated_by == "simple"
  end

  test "extra structure that changes predictions is not complexity-penalized" do
    simple = world("simple", "a1", assumptions: ["a"], predictions: ["p"])

    complex =
      world("complex", "a1", assumptions: ["a", "needed"], predictions: ["p", "new prediction"])

    inv0 = investigation(worlds: [simple, complex])
    [unit] = Aggregator.evidence_units(inv0)

    inv =
      inv0
      |> Investigation.add_judgments([
        compatibility("j1", "simple", unit.id, "obs1", 0),
        compatibility("j2", "complex", unit.id, "obs1", 2)
      ])
      |> Aggregator.run()

    assert inv.worlds["complex"].redundancy_dominated_by == nil
    assert inv.worlds["complex"].fit_score > inv.worlds["simple"].fit_score
  end

  test "newer-round judgment supersedes an older immutable judgment for the same evidence unit" do
    w = world("w", "a1")
    inv0 = investigation(worlds: [w])
    [unit] = Aggregator.evidence_units(inv0)

    inv =
      inv0
      |> Investigation.add_judgments([
        compatibility("old", "w", unit.id, "obs1", -1, 0),
        compatibility("new", "w", unit.id, "obs1", 2, 1)
      ])
      |> Aggregator.run()

    assert_in_delta inv.worlds["w"].fit_score, 1.0, 1.0e-9
  end
end

defmodule LatentInvestigator.AggregatorUncertainDependenceTest do
  use ExUnit.Case, async: true
  import LatentInvestigator.TestFixtures
  alias LatentInvestigator.{Aggregator, Investigation, Provenance}

  test "uncertain dependence caps the joint evidence-unit contribution" do
    graph = Provenance.new() |> Provenance.put_edge("ra", "rb", :uncertain_related)

    inv0 =
      investigation(
        observations: [
          observation("a", provenance_ref: "ra"),
          observation("b", provenance_ref: "rb")
        ],
        worlds: [world("w", "a1", observation_id: "a")]
      )

    inv0 = %{inv0 | provenance: graph}
    [unit] = Aggregator.evidence_units(inv0)

    inv =
      inv0
      |> Investigation.add_judgments([compatibility("j", "w", unit.id, "a", 2)])
      |> Aggregator.run()

    assert unit.dependence == :uncertain
    assert_in_delta inv.worlds["w"].fit_score, 0.5, 1.0e-9
  end
end
