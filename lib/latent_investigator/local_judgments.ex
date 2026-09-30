defmodule LatentInvestigator.LocalJudgments do
  @moduledoc "Builds bounded logical requests from alive worlds and provenance-grouped evidence."
  alias LatentInvestigator.{Aggregator, Investigation, World}
  alias LatentInvestigator.Evaluator.JudgmentRequest

  @compatibility_rubric %{
    strongly_against: "Evidence is materially difficult to reconcile with this world.",
    against: "Evidence weighs against this world.",
    neutral: "Evidence is compatible but not discriminating.",
    supports: "Evidence is more expected in this world than salient alternatives.",
    strongly_supports: "Evidence is strongly characteristic of this world."
  }

  def compatibility_requests(%Investigation{} = inv) do
    units = Aggregator.evidence_units(inv)

    for %World{} = world <- Investigation.alive_worlds(inv), unit <- units, reduce: [] do
      acc ->
        canonical = List.first(unit.observations)

        request =
          JudgmentRequest.new(%{
            kind: :observation_compatibility,
            world_id: world.id,
            observation_id: canonical && canonical.id,
            subject_refs: unit.observation_ids,
            round: inv.round,
            rubric: @compatibility_rubric,
            state: %{
              world: bounded_world(world),
              evidence_unit: %{
                id: unit.id,
                dependence: unit.dependence,
                observations: Enum.map(unit.observations, &bounded_observation/1)
              },
              actors: referenced_actors(inv, world)
            },
            metadata: %{evidence_unit_id: unit.id}
          })

        if Map.has_key?(inv.judgments, request.id), do: acc, else: [request | acc]
    end
    |> Enum.reverse()
  end

  defp bounded_world(world) do
    Map.take(Map.from_struct(world), [
      :id,
      :summary,
      :mechanism_family,
      :actor_roles,
      :actor_knowledge,
      :causal_links,
      :source_hypotheses,
      :assumptions,
      :predictions,
      :falsifiers
    ])
  end

  defp bounded_observation(obs) do
    Map.take(Map.from_struct(obs), [
      :id,
      :round,
      :timestamp,
      :surface,
      :observation_type,
      :claimed_source,
      :authenticated_source,
      :provenance_ref,
      :access_level,
      :metadata
    ])
  end

  defp referenced_actors(inv, world) do
    ids =
      (Enum.map(world.actor_roles, &value(&1, :actor_id)) ++
         Enum.map(world.actor_knowledge, &value(&1, :actor_id)) ++
         Enum.map(world.source_hypotheses, &value(&1, :source_actor_id)))
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    ids
    |> Enum.map(&Map.get(inv.actors, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Map.from_struct/1)
  end

  defp value(map, key), do: Map.get(map, key, Map.get(map, to_string(key)))
end
