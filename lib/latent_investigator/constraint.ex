defmodule LatentInvestigator.Constraint do
  @moduledoc "Deterministic hard facts. Semantic plausibility does not belong here."
  alias LatentInvestigator.{Investigation, Util, World}

  def failures(%Investigation{} = inv, %World{} = world) do
    []
    |> Kernel.++(reference_failures(inv, world))
    |> Kernel.++(authenticated_source_failures(inv, world))
    |> Kernel.++(chronology_failures(inv, world))
    |> Kernel.++(authenticated_mechanism_failures(inv, world))
    |> Kernel.++(capability_failures(inv, world))
  end

  def apply(%Investigation{} = inv, %World{} = world) do
    case failures(inv, world) do
      [] -> %{world | hard_failures: []}
      failures -> %{world | status: :rejected, hard_failures: failures, fit_score: nil}
    end
  end

  defp reference_failures(inv, world) do
    actor_ids = Map.keys(inv.actors) |> MapSet.new()
    observation_ids = Map.keys(inv.observations) |> MapSet.new()

    actor_refs =
      (Enum.flat_map(world.actor_roles, &[Util.get(&1, :actor_id)]) ++
         Enum.flat_map(world.actor_knowledge, &[Util.get(&1, :actor_id)]) ++
         Enum.flat_map(world.source_hypotheses, &[Util.get(&1, :source_actor_id)]))
      |> Enum.reject(&is_nil/1)

    observation_refs =
      world.source_hypotheses
      |> Enum.map(&Util.get(&1, :observation_id))
      |> Enum.reject(&is_nil/1)

    actor_failures =
      for id <- actor_refs,
          not MapSet.member?(actor_ids, id),
          do: %{code: :unknown_actor_ref, ref: id}

    obs_failures =
      for id <- observation_refs,
          not MapSet.member?(observation_ids, id),
          do: %{code: :unknown_observation_ref, ref: id}

    actor_failures ++ obs_failures
  end

  defp authenticated_source_failures(inv, world) do
    Enum.flat_map(inv.observations, fn {_id, obs} ->
      target_id = Util.get(obs.metadata, :authenticates_observation_id)
      authenticated = obs.authenticated_source

      cond do
        is_binary(target_id) and not is_nil(authenticated) ->
          source_conflict(world, target_id, authenticated)

        not is_nil(authenticated) ->
          source_conflict(world, obs.id, authenticated)

        true ->
          []
      end
    end)
  end

  defp source_conflict(world, observation_id, authenticated) do
    case World.source_actor(world, observation_id) do
      nil ->
        []

      ^authenticated ->
        []

      proposed ->
        [
          %{
            code: :authenticated_source_conflict,
            observation_id: observation_id,
            expected: authenticated,
            proposed: proposed
          }
        ]
    end
  end

  defp chronology_failures(inv, world) do
    Enum.flat_map(world.source_hypotheses, fn hypothesis ->
      actor_id = Util.get(hypothesis, :source_actor_id)
      observation_id = Util.get(hypothesis, :observation_id)
      observation = Map.get(inv.observations, observation_id)

      if observation && is_binary(observation.timestamp) do
        world.actor_knowledge
        |> Enum.filter(fn item ->
          Util.get(item, :actor_id) == actor_id and Util.get(item, :status) in [:knows, "knows"]
        end)
        |> Enum.flat_map(fn item ->
          by_time = Util.get(item, :by_time)

          if after?(by_time, observation.timestamp) do
            [
              %{
                code: :knowledge_after_observation,
                actor_id: actor_id,
                fact_id: Util.get(item, :fact_id),
                by_time: by_time,
                observation_id: observation_id,
                observation_time: observation.timestamp
              }
            ]
          else
            []
          end
        end)
      else
        []
      end
    end)
  end

  defp after?(left, right) when is_binary(left) and is_binary(right) do
    with {:ok, l, _} <- DateTime.from_iso8601(left),
         {:ok, r, _} <- DateTime.from_iso8601(right) do
      DateTime.compare(l, r) == :gt
    else
      _ -> false
    end
  end

  defp after?(_, _), do: false

  defp authenticated_mechanism_failures(inv, world) do
    inv.observations
    |> Map.values()
    |> Enum.flat_map(fn obs ->
      case Util.get(obs.metadata, :authenticates_mechanism) do
        mechanism when is_binary(mechanism) and mechanism != "" ->
          if world.mechanism_family == mechanism do
            []
          else
            [
              %{
                code: :authenticated_mechanism_conflict,
                observation_id: obs.id,
                expected: mechanism,
                proposed: world.mechanism_family
              }
            ]
          end

        _ ->
          []
      end
    end)
  end

  defp capability_failures(inv, world) do
    Enum.flat_map(world.source_hypotheses, fn hypothesis ->
      actor_id = Util.get(hypothesis, :source_actor_id)
      mechanism = Util.get(hypothesis, :mechanism)

      case Map.get(inv.actors, actor_id) do
        nil ->
          []

        actor ->
          if mechanism in [
               "published",
               "posted",
               "direct_message",
               :published,
               :posted,
               :direct_message
             ] and
               not (:publish in actor.capabilities or "publish" in actor.capabilities) do
            [
              %{
                code: :actor_lacks_publish_capability,
                actor_id: actor_id,
                observation_id: Util.get(hypothesis, :observation_id)
              }
            ]
          else
            []
          end
      end
    end)
  end
end
