defmodule LatentInvestigator.World do
  @moduledoc "Structured causal world proposal."
  alias LatentInvestigator.{ID, Util}

  @statuses [:alive, :rejected, :pruned, :merged]

  defstruct [
    :id,
    :summary,
    :mechanism_family,
    :status,
    :fit_score,
    :redundancy_dominated_by,
    actor_roles: [],
    actor_knowledge: [],
    causal_links: [],
    source_hypotheses: [],
    assumptions: [],
    predictions: [],
    falsifiers: [],
    generation: %{},
    hard_failures: [],
    parent_ids: [],
    metadata: %{}
  ]

  @type t :: %__MODULE__{}

  def from_candidate(attrs, generation \\ %{}) do
    client_id = Util.get(attrs, :client_id)

    id =
      if is_binary(client_id) and client_id != "",
        do: client_id,
        else: ID.stable("world", execution_shape(attrs))

    %__MODULE__{
      id: id,
      summary: Util.string(Util.get(attrs, :summary, "")),
      mechanism_family: Util.string(Util.get(attrs, :mechanism_family, "unknown")),
      actor_roles: Util.list(Util.get(attrs, :actor_roles, [])),
      actor_knowledge: Util.list(Util.get(attrs, :actor_knowledge, [])),
      causal_links: Util.list(Util.get(attrs, :causal_links, [])),
      source_hypotheses: Util.list(Util.get(attrs, :source_hypotheses, [])),
      assumptions: Util.list(Util.get(attrs, :assumptions, [])),
      predictions: Util.list(Util.get(attrs, :predictions, [])),
      falsifiers: Util.list(Util.get(attrs, :falsifiers, [])),
      generation: Map.merge(Util.map(Util.get(attrs, :generation, %{})), Util.map(generation)),
      parent_ids: Util.list(Util.get(attrs, :parent_ids, Util.get(generation, :parent_ids, []))),
      metadata: Util.map(Util.get(attrs, :metadata, %{})),
      status: :alive,
      fit_score: nil,
      hard_failures: []
    }
  end

  def execution_shape(%__MODULE__{} = world), do: execution_shape(Map.from_struct(world))

  def execution_shape(attrs) do
    %{
      mechanism_family: Util.get(attrs, :mechanism_family, "unknown"),
      actor_roles: normalize_list(Util.get(attrs, :actor_roles, [])),
      actor_knowledge: normalize_list(Util.get(attrs, :actor_knowledge, [])),
      causal_links: normalize_list(Util.get(attrs, :causal_links, [])),
      source_hypotheses: normalize_list(Util.get(attrs, :source_hypotheses, [])),
      assumptions:
        Enum.sort(Enum.map(Util.list(Util.get(attrs, :assumptions, [])), &to_string/1)),
      predictions:
        Enum.sort(Enum.map(Util.list(Util.get(attrs, :predictions, [])), &to_string/1)),
      falsifiers: Enum.sort(Enum.map(Util.list(Util.get(attrs, :falsifiers, [])), &to_string/1))
    }
  end

  def signature(world), do: ID.stable("sig", execution_shape(world))
  def status?(%__MODULE__{status: status}, status) when status in @statuses, do: true
  def status?(_, _), do: false

  def source_actor(%__MODULE__{} = world, observation_id) do
    Enum.find_value(world.source_hypotheses, fn h ->
      if Util.get(h, :observation_id) == observation_id, do: Util.get(h, :source_actor_id)
    end)
  end

  def actor_role(%__MODULE__{} = world, actor_id) do
    Enum.find_value(world.actor_roles, fn role ->
      if Util.get(role, :actor_id) == actor_id, do: Util.get(role, :role)
    end)
  end

  def actor_knowledge_status(%__MODULE__{} = world, actor_id, fact_id) do
    Enum.find_value(world.actor_knowledge, fn item ->
      if Util.get(item, :actor_id) == actor_id and Util.get(item, :fact_id) == fact_id,
        do: Util.get(item, :status)
    end)
  end

  defp normalize_list(value) do
    value |> Util.list() |> Enum.map(&Util.canonical/1) |> Enum.sort_by(&inspect/1)
  end
end
