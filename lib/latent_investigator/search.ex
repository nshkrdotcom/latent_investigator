defmodule LatentInvestigator.Search do
  @moduledoc "Soft pruning with protected mechanism diversity."
  alias LatentInvestigator.World

  def prune(worlds, opts \\ []) do
    max_alive = Keyword.get(opts, :max_alive_worlds, 32)
    fit_gap = Keyword.get(opts, :fit_gap_limit, 0.75)
    protected = Keyword.get(opts, :protected_diversity_slots, 4)

    alive = Enum.filter(worlds, &(&1.status == :alive))
    best_fit = alive |> Enum.map(&(&1.fit_score || -1.0)) |> Enum.max(fn -> -1.0 end)

    eligible =
      Enum.filter(alive, fn w -> is_nil(w.fit_score) or best_fit - w.fit_score <= fit_gap end)

    diverse =
      eligible
      |> Enum.group_by(& &1.mechanism_family)
      |> Enum.map(fn {_family, ws} -> best(ws) end)
      |> Enum.sort_by(&rank_key/1)
      |> Enum.take(protected)

    diverse_ids = MapSet.new(diverse, & &1.id)

    fill =
      eligible |> Enum.reject(&MapSet.member?(diverse_ids, &1.id)) |> Enum.sort_by(&rank_key/1)

    keep_ids = (diverse ++ fill) |> Enum.take(max_alive) |> MapSet.new(& &1.id)

    Enum.map(worlds, fn
      %World{status: :alive} = world ->
        if MapSet.member?(keep_ids, world.id), do: world, else: %{world | status: :pruned}

      world ->
        world
    end)
  end

  def rank(worlds), do: Enum.sort_by(worlds, &rank_key/1)

  defp best(worlds), do: worlds |> Enum.sort_by(&rank_key/1) |> List.first()

  defp rank_key(world),
    do: {world.redundancy_dominated_by != nil, -(world.fit_score || -1.0), world.id}
end
