defmodule LatentInvestigator.Target do
  @moduledoc "Access-relative target resolution from surviving structured worlds."
  alias LatentInvestigator.{Util, World}

  def resolve(worlds, target) do
    stances =
      worlds
      |> Enum.filter(&(&1.status == :alive))
      |> Enum.map(&stance(&1, Util.get(target, :query, %{})))
      |> Enum.reject(&is_nil/1)

    cond do
      stances == [] -> :unresolved
      Enum.all?(stances, &(&1 == :supports)) -> :supported
      Enum.all?(stances, &(&1 == :rejects)) -> :rejected
      true -> :unresolved
    end
  end

  def stance(%World{} = world, query) do
    case Util.get(query, :kind) do
      kind when kind in [:mechanism_family, "mechanism_family"] ->
        if world.mechanism_family == Util.get(query, :value), do: :supports, else: :rejects

      kind when kind in [:source_actor, "source_actor"] ->
        expected_actor = Util.get(query, :actor_id)

        case World.source_actor(world, Util.get(query, :observation_id)) do
          nil -> nil
          ^expected_actor -> :supports
          _ -> :rejects
        end

      kind when kind in [:actor_role, "actor_role"] ->
        expected_role = Util.get(query, :role)

        case World.actor_role(world, Util.get(query, :actor_id)) do
          nil -> nil
          ^expected_role -> :supports
          _ -> :rejects
        end

      kind when kind in [:actor_knows, "actor_knows"] ->
        case World.actor_knowledge_status(
               world,
               Util.get(query, :actor_id),
               Util.get(query, :fact_id)
             ) do
          status when status in [:knows, "knows"] -> :supports
          status when status in [:does_not_know, "does_not_know"] -> :rejects
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
