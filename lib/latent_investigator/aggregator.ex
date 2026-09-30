defmodule LatentInvestigator.Aggregator do
  @moduledoc "Hard constraints, provenance-aware ordinal fit, redundancy dominance and soft pruning."
  alias LatentInvestigator.{Constraint, Investigation, Provenance, Search, Util, World}

  def run(%Investigation{} = inv, opts \\ []) do
    worlds = inv.worlds |> Map.values() |> Enum.map(&Constraint.apply(inv, &1))
    units = Provenance.evidence_units(inv.provenance, Investigation.observations(inv))
    worlds = Enum.map(worlds, &score_world(&1, inv, units))
    worlds = apply_redundancy_dominance(worlds, inv, units)
    worlds = Search.prune(worlds, opts)
    ranked = worlds |> Enum.filter(&(&1.status == :alive)) |> Search.rank()

    snapshot =
      Enum.map(
        ranked,
        &%{id: &1.id, fit_score: &1.fit_score, mechanism_family: &1.mechanism_family}
      )

    world_states =
      Enum.map(
        worlds,
        &%{
          id: &1.id,
          status: &1.status,
          fit_score: &1.fit_score,
          hard_failures: &1.hard_failures,
          redundancy_dominated_by: &1.redundancy_dominated_by
        }
      )

    %{
      inv
      | worlds: Map.new(worlds, &{&1.id, &1}),
        history:
          inv.history ++
            [
              %{
                type: :aggregation_completed,
                round: inv.round,
                evidence_units: length(units),
                ranked_worlds: snapshot,
                world_states: world_states
              }
            ]
    }
  end

  def evidence_units(%Investigation{} = inv),
    do: Provenance.evidence_units(inv.provenance, Investigation.observations(inv))

  defp score_world(%World{status: status} = world, _inv, _units) when status != :alive, do: world

  defp score_world(world, inv, units) do
    weights = Enum.map(units, &unit_weight(inv, world.id, &1))
    present = Enum.reject(weights, &is_nil/1)
    score = if units == [], do: 0.0, else: Enum.sum(present) / (2.0 * length(units))
    %{world | fit_score: score}
  end

  defp unit_weight(inv, world_id, unit) do
    ids = MapSet.new(unit.observation_ids)

    matches =
      inv.judgments
      |> Map.values()
      |> Enum.filter(fn j ->
        j.world_id == world_id and
          j.kind in [:observation_compatibility, "observation_compatibility"] and
          (j.observation_id in ids or j.subject_ref == unit.id)
      end)

    case matches do
      [] ->
        nil

      values ->
        latest_round = values |> Enum.map(& &1.round) |> Enum.max()
        latest = Enum.filter(values, &(&1.round == latest_round))

        case latest do
          [judgment] ->
            scale_weight(judgment.ordinal_weight, unit.dependence)

          _ ->
            raise ArgumentError,
                  "multiple compatibility judgments for world #{world_id}, evidence unit #{unit.id}, round #{latest_round}"
        end
    end
  end

  defp scale_weight(nil, _dependence), do: nil
  defp scale_weight(weight, :uncertain), do: weight * 0.5
  defp scale_weight(weight, _dependence), do: weight

  defp apply_redundancy_dominance(worlds, inv, units) do
    alive = Enum.filter(worlds, &(&1.status == :alive))

    dominance =
      for small <- alive,
          big <- alive,
          small.id != big.id,
          redundant_superset?(small, big, inv, units),
          into: %{} do
        {big.id, small.id}
      end

    Enum.map(worlds, fn world ->
      case Map.get(dominance, world.id) do
        nil -> %{world | redundancy_dominated_by: nil}
        dominator -> %{world | redundancy_dominated_by: dominator}
      end
    end)
  end

  defp redundant_superset?(small, big, inv, units) do
    same_predictions = normalized(small.predictions) == normalized(big.predictions)

    same_pattern =
      Enum.map(units, &unit_weight(inv, small.id, &1)) ==
        Enum.map(units, &unit_weight(inv, big.id, &1))

    extra_assumptions = strict_superset?(big.assumptions, small.assumptions)
    extra_edges = superset?(big.causal_links, small.causal_links)
    extra_falsifiers = normalized(big.falsifiers) == normalized(small.falsifiers)
    same_predictions and same_pattern and extra_assumptions and extra_edges and extra_falsifiers
  end

  defp strict_superset?(left, right) do
    l = MapSet.new(Enum.map(left, &Util.canonical/1))
    r = MapSet.new(Enum.map(right, &Util.canonical/1))
    MapSet.subset?(r, l) and MapSet.size(l) > MapSet.size(r)
  end

  defp superset?(left, right) do
    l = MapSet.new(Enum.map(left, &Util.canonical/1))
    r = MapSet.new(Enum.map(right, &Util.canonical/1))
    MapSet.subset?(r, l)
  end

  defp normalized(items), do: items |> Enum.map(&Util.canonical/1) |> Enum.sort_by(&inspect/1)
end
