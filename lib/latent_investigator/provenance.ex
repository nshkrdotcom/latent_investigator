defmodule LatentInvestigator.Provenance do
  @moduledoc "Investigator-known provenance graph. Hidden simulator provenance never belongs here."
  alias LatentInvestigator.{Observation, Util}

  @dependent_types [:derived_from, :quoted_from, :paraphrased_from, :copied_from, :spoofed_as]
  @uncertain_types [:uncertain_related]
  @edge_types @dependent_types ++ @uncertain_types ++ [:independent_of]

  defstruct nodes: %{}, edges: []
  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  def put_node(%__MODULE__{} = graph, id, attrs \\ %{}) do
    id = to_string(id)
    %{graph | nodes: Map.put(graph.nodes, id, Map.put(Util.map(attrs), :id, id))}
  end

  def put_edge(%__MODULE__{} = graph, from, to, type, metadata \\ %{}) when type in @edge_types do
    from = to_string(from)
    to = to_string(to)
    graph = graph |> put_node(from) |> put_node(to)
    edge = %{from: from, to: to, type: type, metadata: Util.map(metadata)}
    if edge in graph.edges, do: graph, else: %{graph | edges: [edge | graph.edges]}
  end

  def put_edge(_graph, _from, _to, type, _metadata), do: raise(ArgumentError, "unsupported provenance edge #{inspect(type)}")

  def merge(%__MODULE__{} = left, %__MODULE__{} = right) do
    %__MODULE__{nodes: Map.merge(left.nodes, right.nodes), edges: Enum.uniq(left.edges ++ right.edges)}
  end

  def evidence_units(%__MODULE__{} = graph, observations) do
    observations = Enum.map(observations, &normalize_observation/1)
    obs_nodes = Map.new(observations, &{&1.id, provenance_id(&1)})
    adjacency = dependency_adjacency(graph)

    {units, _seen} =
      Enum.reduce(observations, {[], MapSet.new()}, fn obs, {units, seen} ->
        node = Map.fetch!(obs_nodes, obs.id)
        if MapSet.member?(seen, node) do
          {units, seen}
        else
          component = component(node, adjacency)
          member_obs = Enum.filter(observations, fn candidate -> Map.fetch!(obs_nodes, candidate.id) in component end)
          seen = Enum.reduce(component, seen, &MapSet.put(&2, &1))
          id = component |> Enum.sort() |> Enum.join("|") |> then(&:crypto.hash(:sha256, &1)) |> Base.encode16(case: :lower) |> binary_part(0, 12)
          unit = %{
            id: "evidence_#{id}",
            observation_ids: Enum.map(member_obs, & &1.id),
            provenance_refs: Enum.sort(component),
            observations: member_obs,
            dependence: component_dependence(graph, component, member_obs)
          }
          {[unit | units], seen}
        end
      end)

    Enum.sort_by(units, & &1.id)
  end

  defp normalize_observation(%Observation{} = obs), do: obs
  defp normalize_observation(attrs), do: Observation.new(attrs)
  defp provenance_id(%Observation{provenance_ref: nil, id: id}), do: "observation:#{id}"
  defp provenance_id(%Observation{provenance_ref: ref}), do: to_string(ref)

  defp dependency_adjacency(graph) do
    base = Map.new(Map.keys(graph.nodes), &{&1, MapSet.new()})
    Enum.reduce(graph.edges, base, fn edge, acc ->
      if edge.type in @dependent_types ++ @uncertain_types do
        acc |> connect(edge.from, edge.to) |> connect(edge.to, edge.from)
      else
        acc
      end
    end)
  end

  defp component_dependence(_graph, _component, [_single]), do: :single
  defp component_dependence(graph, component, _observations) do
    refs = MapSet.new(component)
    edges = Enum.filter(graph.edges, &(MapSet.member?(refs, &1.from) and MapSet.member?(refs, &1.to)))
    if Enum.any?(edges, &(&1.type in @uncertain_types)), do: :uncertain, else: :known_dependent
  end

  defp connect(map, from, to), do: Map.update(map, from, MapSet.new([to]), &MapSet.put(&1, to))

  defp component(start, adjacency), do: walk([start], adjacency, MapSet.new()) |> MapSet.to_list()
  defp walk([], _adjacency, seen), do: seen
  defp walk([node | rest], adjacency, seen) do
    if MapSet.member?(seen, node) do
      walk(rest, adjacency, seen)
    else
      next = Map.get(adjacency, node, MapSet.new()) |> MapSet.to_list()
      walk(next ++ rest, adjacency, MapSet.put(seen, node))
    end
  end
end
