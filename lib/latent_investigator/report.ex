defmodule LatentInvestigator.Report do
  @moduledoc "Auditable final structured-investigation report."
  alias LatentInvestigator.{Investigation, Search, Target}

  def build(%Investigation{} = inv, task_targets \\ [], opts \\ []) do
    alive = inv |> Investigation.alive_worlds() |> Search.rank()
    rejected = inv.worlds |> Map.values() |> Enum.filter(&(&1.status == :rejected))
    targets = Map.new(task_targets, fn target -> {to_string(target.id || target["id"]), Atom.to_string(Target.resolve(alive, target))} end)

    %{
      investigation_id: inv.id,
      round: inv.round,
      leading_worlds: Enum.map(alive, &world_summary/1),
      rejected_worlds: Enum.map(rejected, &%{id: &1.id, summary: &1.summary, hard_failures: &1.hard_failures}),
      target_statuses: targets,
      unresolved: Enum.filter(targets, fn {_id, status} -> status == "unresolved" end) |> Enum.map(&elem(&1, 0)),
      provenance_groups: LatentInvestigator.Provenance.evidence_units(inv.provenance, Investigation.observations(inv)) |> Enum.map(&Map.take(&1, [:id, :observation_ids, :dependence])),
      actions: Enum.filter(inv.history, &(&1[:type] == :evidence_action_executed)),
      generation_coverage_warning: Keyword.get(opts, :generation_coverage_warning, false),
      resource_summary: resource_summary(inv)
    }
  end

  defp world_summary(world), do: %{id: world.id, summary: world.summary, mechanism_family: world.mechanism_family, fit_score: world.fit_score, assumptions: world.assumptions, predictions: world.predictions, falsifiers: world.falsifiers, redundancy_dominated_by: world.redundancy_dominated_by}

  defp resource_summary(inv) do
    judgments = Map.values(inv.judgments)
    local_calls = local_transport_calls(judgments)
    generation = generation_calls(inv)
    local_input = Enum.reduce(local_calls, 0, fn j, acc -> acc + token(j.usage, :input_tokens) end)
    local_output = Enum.reduce(local_calls, 0, fn j, acc -> acc + token(j.usage, :output_tokens) end)
    generation_input = Enum.reduce(generation, 0, fn item, acc -> acc + token(item.usage, :input_tokens) end)
    generation_output = Enum.reduce(generation, 0, fn item, acc -> acc + token(item.usage, :output_tokens) end)
    local_cost = Enum.reduce(local_calls, 0.0, fn j, acc -> if is_number(j.cost), do: acc + j.cost, else: acc end)
    generation_cost = Enum.reduce(generation, 0.0, fn item, acc -> if is_number(item.cost), do: acc + item.cost, else: acc end)

    %{
      local_judgments: length(judgments),
      local_transport_calls: length(local_calls),
      generation_calls: length(generation),
      frontier_calls: length(local_calls) + length(generation),
      by_provider: Enum.frequencies_by(judgments, &(&1.provider || :unknown)),
      input_tokens: local_input + generation_input,
      output_tokens: local_output + generation_output,
      reported_cost: local_cost + generation_cost
    }
  end

  defp local_transport_calls(judgments) do
    judgments
    |> Enum.group_by(fn judgment ->
      judgment.metadata[:transport_call_id] || judgment.batch_id || judgment.request_id || judgment.id
    end)
    |> Enum.map(fn {_transport_id, group} -> List.first(group) end)
  end

  defp generation_calls(inv) do
    inv.worlds
    |> Map.values()
    |> Enum.map(fn world ->
      generation = world.generation || %{}
      %{
        key: {generation[:round], generation[:mode], generation[:response_id]},
        usage: generation[:usage] || %{},
        cost: generation[:cost]
      }
    end)
    |> Enum.reject(fn item -> item.key == {nil, nil, nil} end)
    |> Enum.uniq_by(& &1.key)
  end

  defp token(usage, key) when is_map(usage) do
    value = Map.get(usage, key) || Map.get(usage, to_string(key))
    if is_integer(value), do: value, else: 0
  end

  defp token(_, _), do: 0
end
