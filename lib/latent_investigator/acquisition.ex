defmodule LatentInvestigator.Acquisition do
  @moduledoc "Simulator-relative pair-separation evidence selection."
  alias LatentInvestigator.{EvidenceAction, Investigation}

  def choose(%Investigation{} = inv, actions, simulator, opts \\ []) do
    worlds = Investigation.alive_worlds(inv)
    scored = Enum.map(actions, &score_action(worlds, &1, simulator, opts))
    case Enum.sort_by(scored, fn s -> {-s.utility, -s.separated_pairs, s.action.cost_units || 1, s.action.id} end) do
      [] -> :none
      [best | _] -> {:ok, best}
    end
  end

  def score_action(worlds, %EvidenceAction{} = action, simulator, opts \\ []) do
    pairs = unordered_pairs(worlds)
    predictions = Map.new(worlds, fn world -> {world.id, simulator.predict(world, action, opts)} end)
    separated = Enum.count(pairs, fn {left, right} -> separated?(predictions[left.id], predictions[right.id]) end)
    total = length(pairs)
    separation = if total == 0, do: 0.0, else: separated / total
    cost = max(action.cost_units || 1, 1)
    %{action: action, separated_pairs: separated, total_pairs: total, separation: separation, utility: separation / cost, predictions: predictions}
  end

  defp separated?({:ok, left}, {:ok, right}), do: left != right
  defp separated?(_, _), do: false

  defp unordered_pairs(list) do
    list |> Enum.with_index() |> Enum.flat_map(fn {left, i} -> list |> Enum.drop(i + 1) |> Enum.map(&{left, &1}) end)
  end
end
