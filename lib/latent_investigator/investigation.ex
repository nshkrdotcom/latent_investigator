defmodule LatentInvestigator.Investigation do
  @moduledoc "Authoritative append-oriented structured investigation state."
  alias LatentInvestigator.{Actor, EvidenceAction, ID, Observation, Provenance, World, Judgment, Util}

  defstruct [
    :id, round: 0, observations: %{}, actors: %{}, worlds: %{}, judgments: %{},
    provenance: %Provenance{}, actions: %{}, history: [], config: %{}
  ]
  @type t :: %__MODULE__{}

  def new(attrs \\ []) do
    %__MODULE__{
      id: Util.get(attrs, :id, ID.new("investigation")),
      round: Util.get(attrs, :round, 0),
      provenance: Util.get(attrs, :provenance, Provenance.new()),
      config: Util.map(Util.get(attrs, :config, %{}))
    }
    |> put_actors(Util.get(attrs, :actors, []))
    |> admit_observations(Util.get(attrs, :observations, []))
    |> put_actions(Util.get(attrs, :actions, []))
  end

  def put_actors(%__MODULE__{} = inv, actors) do
    registry = Enum.reduce(actors, inv.actors, fn actor, acc ->
      actor = if is_struct(actor, Actor), do: actor, else: Actor.new(actor)
      Map.put(acc, actor.id, actor)
    end)
    %{inv | actors: registry}
  end

  def admit_observations(%__MODULE__{} = inv, observations) do
    {registry, events} = Enum.reduce(observations, {inv.observations, []}, fn obs, {acc, events} ->
      obs = if is_struct(obs, Observation), do: obs, else: Observation.new(obs)
      if Map.has_key?(acc, obs.id) do
        {acc, events}
      else
        {Map.put(acc, obs.id, obs), [%{type: :observation_admitted, observation_id: obs.id, round: inv.round} | events]}
      end
    end)
    %{inv | observations: registry, history: inv.history ++ Enum.reverse(events)}
  end

  def put_actions(%__MODULE__{} = inv, actions) do
    registry = Enum.reduce(actions, inv.actions, fn action, acc ->
      action = if is_struct(action, EvidenceAction), do: action, else: EvidenceAction.new(action)
      Map.put(acc, action.id, action)
    end)
    %{inv | actions: registry}
  end

  def add_worlds(%__MODULE__{} = inv, worlds) do
    {registry, events} = Enum.reduce(worlds, {inv.worlds, []}, fn world, {acc, events} ->
      world = if is_struct(world, World), do: world, else: World.from_candidate(world)
      signature = World.signature(world)
      duplicate = Enum.find(acc, fn {_id, existing} -> World.signature(existing) == signature end)

      if duplicate do
        {acc, events}
      else
        {world, collision_event} = unique_world_id(world, acc, inv.round)
        next_events = [%{type: :world_admitted, world_id: world.id, round: inv.round} | collision_event ++ events]
        {Map.put(acc, world.id, world), next_events}
      end
    end)
    %{inv | worlds: registry, history: inv.history ++ Enum.reverse(events)}
  end

  defp unique_world_id(%World{} = world, registry, round) do
    if Map.has_key?(registry, world.id) do
      submitted_id = world.id
      replacement = ID.stable("world", {submitted_id, World.execution_shape(world)})
      replacement = unique_suffix(replacement, registry, 0)
      world = %{world | id: replacement, metadata: Map.put(world.metadata, :submitted_id_collision, submitted_id)}
      event = [%{type: :world_id_collision, submitted_id: submitted_id, replacement_id: replacement, round: round}]
      {world, event}
    else
      {world, []}
    end
  end

  defp unique_suffix(id, registry, attempt) do
    candidate = if attempt == 0, do: id, else: "#{id}_#{attempt}"
    if Map.has_key?(registry, candidate), do: unique_suffix(id, registry, attempt + 1), else: candidate
  end

  def update_world(%__MODULE__{} = inv, %World{id: id} = world) do
    if Map.has_key?(inv.worlds, id) do
      %{inv | worlds: Map.put(inv.worlds, id, world), history: inv.history ++ [%{type: :world_updated, world_id: id, status: world.status, round: inv.round}]}
    else
      raise ArgumentError, "cannot update unknown world #{inspect(id)}"
    end
  end

  def add_judgments(%__MODULE__{} = inv, judgments) do
    {registry, events} = Enum.reduce(judgments, {inv.judgments, []}, fn j, {acc, events} ->
      j = if is_struct(j, Judgment), do: j, else: Judgment.new(j)
      if Map.has_key?(acc, j.id), do: raise(ArgumentError, "judgment #{j.id} is immutable and already exists")
      {Map.put(acc, j.id, j), [%{type: :judgment_admitted, judgment_id: j.id, world_id: j.world_id, round: inv.round} | events]}
    end)
    %{inv | judgments: registry, history: inv.history ++ Enum.reverse(events)}
  end

  def advance_round(%__MODULE__{} = inv), do: %{inv | round: inv.round + 1, history: inv.history ++ [%{type: :round_advanced, round: inv.round + 1}]}

  def record_action(%__MODULE__{} = inv, action_id, rationale, observation_ids \\ []) do
    event = %{type: :evidence_action_executed, action_id: action_id, rationale: rationale, observation_ids: observation_ids, round: inv.round}
    %{inv | history: inv.history ++ [event]}
  end

  def alive_worlds(%__MODULE__{} = inv), do: inv.worlds |> Map.values() |> Enum.filter(&(&1.status == :alive))
  def observations(%__MODULE__{} = inv), do: inv.observations |> Map.values() |> Enum.sort_by(&{&1.round, &1.timestamp || "", &1.id})
end
