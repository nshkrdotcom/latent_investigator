defmodule LatentInvestigator.Experiment.Metrics do
  @moduledoc "Small diagnostic metric set for v1.1 gates."
  alias LatentInvestigator.{Util, World}

  @statuses ~w(supported rejected unresolved)

  def target_metrics(report, evaluation_targets) do
    expected = Map.new(evaluation_targets, fn t -> {to_string(Util.get(t, :id)), to_string(Util.get(t, :expected_status))} end)
    predicted = normalize_statuses(report[:target_statuses] || report["target_statuses"] || %{})
    pairs = Enum.map(expected, fn {id, truth} -> {truth, Map.get(predicted, id, "unresolved")} end)
    target_metrics_from_pairs(pairs)
  end

  def target_metrics_from_pairs(pairs) when is_list(pairs) do
    per = Map.new(@statuses, &{&1, prf(pairs, &1)})
    present = Enum.filter(@statuses, fn label -> Enum.any?(pairs, fn {truth, _pred} -> truth == label end) end)
    macro_f1 = present |> Enum.map(&per[&1].f1) |> mean()
    %{macro_f1: macro_f1, per_status: per, confusion: confusion(pairs), count: length(pairs), pairs: pairs}
  end

  def true_world_retention(worlds, truth, simulator) do
    Enum.any?(worlds, fn
      %World{} = world -> simulator.match_world(truth, world).compatible
      attrs when is_map(attrs) -> simulator.match_world(truth, World.from_candidate(attrs)).compatible
      _ -> false
    end)
  end

  def resolution_balanced_accuracy(report, evaluation_targets) do
    expected = Map.new(evaluation_targets, fn t -> {to_string(Util.get(t, :id)), to_string(Util.get(t, :expected_status))} end)
    predicted = normalize_statuses(report[:target_statuses] || report["target_statuses"] || %{})
    pairs = Enum.map(expected, fn {id, truth} -> {truth, Map.get(predicted, id, "unresolved")} end)
    resolution_balanced_accuracy_pairs(pairs)
  end

  def resolution_balanced_accuracy_pairs(pairs) when is_list(pairs) do
    resolution_pairs = Enum.map(pairs, fn {truth, pred} -> {resolution_class(truth), resolution_class(pred)} end)
    present = [:resolved, :unresolved] |> Enum.filter(fn class -> Enum.any?(resolution_pairs, fn {truth, _} -> truth == class end) end)
    present |> Enum.map(fn class -> recall_binary(resolution_pairs, class) end) |> mean()
  end

  def structured_recovery(result, truth, simulator) do
    compatible_ids =
      result.investigation.worlds
      |> Map.values()
      |> Enum.filter(&simulator.match_world(truth, &1).compatible)
      |> MapSet.new(& &1.id)

    snapshots =
      result.investigation.history
      |> Enum.filter(&(&1[:type] == :aggregation_completed))
      |> Enum.sort_by(& &1[:round])
      |> Enum.map(fn event -> {event[:round], Enum.map(event[:ranked_worlds] || [], & &1[:id])} end)

    recovery_from_rankings(snapshots, compatible_ids)
  end

  def baseline_recovery(result, truth, simulator) do
    rankings =
      Enum.map(result.history, fn event ->
        worlds = event.output |> Util.get(:worlds, []) |> sort_baseline_worlds()
        ids =
          worlds
          |> Enum.with_index()
          |> Enum.map(fn {attrs, index} ->
            id = "baseline_#{event.round}_#{index}"
            {id, attrs}
          end)

        compatible = MapSet.new(for {id, attrs} <- ids, simulator.match_world(truth, World.from_candidate(attrs)).compatible, do: id)
        {event.round, Enum.map(ids, &elem(&1, 0)), compatible}
      end)

    initial_false_leader =
      case rankings do
        [{_round, [leader | _], compatible} | _] -> not MapSet.member?(compatible, leader)
        _ -> false
      end

    recovered =
      Enum.find_value(rankings, fn {round, ids, compatible} ->
        case ids do
          [leader | _] -> if MapSet.member?(compatible, leader), do: round, else: nil
          _ -> nil
        end
      end)

    %{success: not is_nil(recovered), recovery_round: recovered, initial_false_leader: initial_false_leader}
  end

  defp recovery_from_rankings(snapshots, compatible_ids) do
    initial_false_leader =
      case snapshots do
        [{_round, [leader | _]} | _] -> not MapSet.member?(compatible_ids, leader)
        _ -> false
      end

    recovered =
      Enum.find_value(snapshots, fn {round, ids} ->
        case ids do
          [leader | _] -> if MapSet.member?(compatible_ids, leader), do: round, else: nil
          _ -> nil
        end
      end)

    %{success: not is_nil(recovered), recovery_round: recovered, initial_false_leader: initial_false_leader}
  end

  defp sort_baseline_worlds(worlds) do
    Enum.sort_by(worlds, fn attrs ->
      support = Util.get(attrs, :relative_support, 0.0)
      if is_number(support), do: -support, else: 0.0
    end)
  end

  defp normalize_statuses(value) when is_map(value), do: Map.new(value, fn {k, v} -> {to_string(k), to_string(v)} end)
  defp normalize_statuses(value) when is_list(value), do: Map.new(value, fn item -> {to_string(item["target_id"] || item[:target_id]), to_string(item["status"] || item[:status])} end)
  defp normalize_statuses(_), do: %{}

  defp prf(pairs, label) do
    tp = Enum.count(pairs, fn {t, p} -> t == label and p == label end)
    fp = Enum.count(pairs, fn {t, p} -> t != label and p == label end)
    fnn = Enum.count(pairs, fn {t, p} -> t == label and p != label end)
    precision = ratio(tp, tp + fp)
    recall = ratio(tp, tp + fnn)
    f1 = if precision + recall == 0, do: 0.0, else: 2 * precision * recall / (precision + recall)
    %{precision: precision, recall: recall, f1: f1, support: tp + fnn}
  end

  defp confusion(pairs) do
    Enum.reduce(pairs, %{}, fn {truth, pred}, acc -> Map.update(acc, {truth, pred}, 1, &(&1 + 1)) end)
  end

  defp resolution_class("unresolved"), do: :unresolved
  defp resolution_class(_), do: :resolved
  defp recall_binary(pairs, class) do
    positives = Enum.filter(pairs, fn {truth, _} -> truth == class end)
    if positives == [], do: 0.0, else: Enum.count(positives, fn {_, pred} -> pred == class end) / length(positives)
  end
  defp ratio(_n, 0), do: 0.0
  defp ratio(n, d), do: n / d
  defp mean([]), do: 0.0
  defp mean(xs), do: Enum.sum(xs) / length(xs)
end
