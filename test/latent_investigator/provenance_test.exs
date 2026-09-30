defmodule LatentInvestigator.ProvenanceTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Observation, Provenance}

  test "surface copies sharing one provenance root form one evidence unit" do
    a = Observation.new(%{id: "a", surface: "a", provenance_ref: "root"})
    b = Observation.new(%{id: "b", surface: "b", provenance_ref: "root"})
    c = Observation.new(%{id: "c", surface: "c", provenance_ref: "other"})

    units = Provenance.evidence_units(Provenance.new(), [a, b, c])
    assert length(units) == 2
    assert Enum.any?(units, &(Enum.sort(&1.observation_ids) == ["a", "b"]))
  end

  test "explicit copied-from edges merge different provenance refs" do
    graph = Provenance.new() |> Provenance.put_edge("root_a", "root_b", :copied_from)
    a = Observation.new(%{id: "a", surface: "a", provenance_ref: "root_a"})
    b = Observation.new(%{id: "b", surface: "b", provenance_ref: "root_b"})
    [unit] = Provenance.evidence_units(graph, [a, b])
    assert Enum.sort(unit.observation_ids) == ["a", "b"]
  end
end

defmodule LatentInvestigator.ProvenanceUncertainTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Observation, Provenance}

  test "uncertain-related evidence is grouped but remains explicitly uncertain" do
    graph = Provenance.new() |> Provenance.put_edge("root_a", "root_b", :uncertain_related)
    a = Observation.new(%{id: "a", surface: "a", provenance_ref: "root_a"})
    b = Observation.new(%{id: "b", surface: "b", provenance_ref: "root_b"})
    [unit] = Provenance.evidence_units(graph, [a, b])
    assert unit.dependence == :uncertain
  end
end
