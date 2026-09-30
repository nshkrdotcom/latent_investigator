defmodule LatentInvestigator.TestFixtures do
  alias LatentInvestigator.{Actor, Investigation, Judgment, Observation, Provenance, World}

  def actor(id),
    do:
      Actor.new(%{
        id: id,
        public_profile: %{label: id},
        capabilities: [:read, :publish],
        channel_access: [:shared_channel]
      })

  def observation(id, opts \\ []) do
    Observation.new(%{
      id: id,
      round: Keyword.get(opts, :round, 0),
      timestamp: Keyword.get(opts, :timestamp, "2026-01-01T00:00:00Z"),
      surface: Keyword.get(opts, :surface, "observation #{id}"),
      claimed_source: Keyword.get(opts, :claimed_source),
      authenticated_source: Keyword.get(opts, :authenticated_source),
      provenance_ref: Keyword.get(opts, :provenance_ref, "root_#{id}"),
      metadata: Keyword.get(opts, :metadata, %{})
    })
  end

  def world(id, source, opts \\ []) do
    World.from_candidate(%{
      client_id: id,
      summary: Keyword.get(opts, :summary, id),
      mechanism_family: Keyword.get(opts, :mechanism_family, "mechanism"),
      actor_roles: [%{actor_id: source, role: Keyword.get(opts, :role, "source")}],
      actor_knowledge: [],
      causal_links: [],
      source_hypotheses: [
        %{
          observation_id: Keyword.get(opts, :observation_id, "obs1"),
          source_actor_id: source,
          mechanism: "published",
          claimed_source_status: "unknown"
        }
      ],
      assumptions: Keyword.get(opts, :assumptions, []),
      predictions: Keyword.get(opts, :predictions, ["p1"]),
      falsifiers: Keyword.get(opts, :falsifiers, ["f1"])
    })
  end

  def investigation(opts \\ []) do
    actors = Keyword.get(opts, :actors, [actor("a1"), actor("a2")])
    observations = Keyword.get(opts, :observations, [observation("obs1")])
    provenance = Keyword.get(opts, :provenance, provenance_for(observations))
    worlds = Keyword.get(opts, :worlds, [])
    judgments = Keyword.get(opts, :judgments, [])

    Investigation.new(actors: actors, observations: observations, provenance: provenance)
    |> Investigation.add_worlds(worlds)
    |> Investigation.add_judgments(judgments)
  end

  def provenance_for(observations) do
    Enum.reduce(observations, Provenance.new(), fn obs, graph ->
      Provenance.put_node(graph, obs.provenance_ref || "observation:#{obs.id}")
    end)
  end

  def compatibility(id, world_id, subject_ref, observation_id, weight, round \\ 0) do
    value =
      Enum.at([:strongly_against, :against, :neutral, :supports, :strongly_supports], weight + 2)

    Judgment.new(%{
      id: id,
      kind: :observation_compatibility,
      subject_ref: subject_ref,
      observation_id: observation_id,
      world_id: world_id,
      value: value,
      ordinal_weight: weight,
      provider: :oracle,
      model: "oracle",
      round: round
    })
  end
end
