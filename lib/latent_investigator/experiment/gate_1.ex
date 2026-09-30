defmodule LatentInvestigator.Experiment.Gate1 do
  @moduledoc "Paired B0a/B0b/B1 qualification with repeated model replicates and compute matching."

  alias LatentInvestigator.{Baseline.Monolithic, Config, Runner}
  alias LatentInvestigator.Evaluator.Context, as: EvaluatorContext
  alias LatentInvestigator.Generator.Context, as: GeneratorContext
  alias LatentInvestigator.Experiment.{Common, CostProjection, Metrics}
  alias LatentInvestigator.Simulator.StrategicNetwork

  def run(opts \\ []) do
    client = Keyword.get(opts, :frontier_client) || Config.inference_client!(:frontier)
    seeds = Keyword.get(opts, :seeds, Enum.to_list(1..10))
    replicates = Keyword.get(opts, :replicates, 3)
    profiles = Keyword.get(opts, :profiles, [:medium])
    case_classes = Keyword.get(opts, :case_classes, [:resolvable, :non_identifiable, :transition])
    access = Keyword.get(opts, :access_regime, :public)
    batch_size = Keyword.get(opts, :judgment_batch_size, 16)

    projection =
      CostProjection.project(
        Keyword.merge(opts,
          profiles: profiles,
          seeds: seeds,
          replicates: replicates,
          case_classes: case_classes
        )
      )

    rows =
      for profile <- profiles,
          case_class <- case_classes,
          seed <- seeds,
          replicate <- 0..(replicates - 1) do
        {:ok, env} = StrategicNetwork.new(seed, profile, case_class, access)

        # B1 runs first so B0b can target the actual structured frontier-token budget.
        {:ok, b1} =
          Runner.run_environment(
            env,
            Keyword.merge(opts,
              simulator: StrategicNetwork,
              generator: LatentInvestigator.Generator.Inference,
              generator_context: %GeneratorContext{client: client, provider: :frontier},
              evaluator: LatentInvestigator.Evaluator.Inference,
              evaluator_context: %EvaluatorContext{
                client: client,
                provider: :frontier,
                config: %{batch_size: batch_size}
              },
              model_replicate: replicate,
              arm: :b1
            )
          )

        b1_score = Common.score_structured(b1, StrategicNetwork)
        target_tokens = resource_tokens(b1_score.resources)

        {:ok, b0a} = Monolithic.run(env, StrategicNetwork, client, :single, opts)

        b0b_opts =
          opts
          |> maybe_put_compute_budget(target_tokens)
          |> Keyword.put_new(:compute_match_max_calls, 64)

        {:ok, b0b} = Monolithic.run(env, StrategicNetwork, client, :iterative, b0b_opts)
        b0a_score = Common.score_baseline(b0a, StrategicNetwork)
        b0b_score = Common.score_baseline(b0b, StrategicNetwork)
        b0b_tokens = resource_tokens(b0b_score.resources)

        %{
          profile: profile,
          case_class: case_class,
          seed: seed,
          replicate: replicate,
          b0a: b0a_score,
          b0b: b0b_score,
          b1: b1_score,
          compute_match: compute_match(target_tokens, b0b_tokens)
        }
      end

    {:ok, %{gate: 1, cost_projection: projection, rows: rows, summary: practical_summary(rows)}}
  end

  defp practical_summary(rows) do
    b0a_target = aggregate_target(rows, :b0a)
    b0b_target = aggregate_target(rows, :b0b)
    b1_target = aggregate_target(rows, :b1)

    {baseline_arm, baseline_target} =
      if b0b_target.macro_f1 >= b0a_target.macro_f1,
        do: {:b0b, b0b_target},
        else: {:b0a, b0a_target}

    b0a_ba = Metrics.resolution_balanced_accuracy_pairs(b0a_target.pairs)
    b0b_ba = Metrics.resolution_balanced_accuracy_pairs(b0b_target.pairs)
    b1_ba = Metrics.resolution_balanced_accuracy_pairs(b1_target.pairs)
    baseline_ba = if baseline_arm == :b0b, do: b0b_ba, else: b0a_ba

    b1_retention = rate(rows, fn row -> row.b1.true_world_retention end)
    baseline_retention = rate(rows, fn row -> row[baseline_arm].true_world_retention end)

    transition_rows = Enum.filter(rows, &(&1.case_class == :transition))
    b1_recovery = recovery_summary(transition_rows, :b1)
    baseline_recovery = recovery_summary(transition_rows, baseline_arm)

    p1_advantage = b1_target.macro_f1 - baseline_target.macro_f1
    p2_advantage = b1_retention - baseline_retention
    p3_success_advantage = b1_recovery.success_rate - baseline_recovery.success_rate

    p3_latency_advantage =
      latency_advantage(baseline_recovery.mean_recovery_round, b1_recovery.mean_recovery_round)

    resolution_delta = b1_ba - baseline_ba
    compute = compute_summary(rows)

    p1 = p1_advantage >= 0.10
    p2_or_p3 = p2_advantage >= 0.10 or p3_success_advantage >= 0.10 or p3_latency_advantage >= 1.0
    guardrail = resolution_delta >= -0.05

    %{
      stronger_monolithic_arm: baseline_arm,
      primary: %{
        p1_final_investigation_macro_f1: %{
          b1: b1_target.macro_f1,
          baseline: baseline_target.macro_f1,
          advantage: p1_advantage,
          threshold: 0.10,
          pass: p1
        },
        p2_true_world_retention: %{
          b1: b1_retention,
          baseline: baseline_retention,
          advantage: p2_advantage
        },
        p3_disconfirmation_recovery: %{
          b1: b1_recovery,
          baseline: baseline_recovery,
          success_advantage: p3_success_advantage,
          recovery_round_advantage: p3_latency_advantage
        }
      },
      resolution_balanced_accuracy: %{
        b1: b1_ba,
        baseline: baseline_ba,
        delta: resolution_delta,
        noninferiority_margin: -0.05,
        pass: guardrail
      },
      compute_match: compute,
      automatic_continuation_precheck: p1 and p2_or_p3 and guardrail,
      requires_manual_validity_review: true,
      note:
        "The precheck is not a publication claim. Continue only after checking compute mismatch, leakage, baseline quality, and failure traces."
    }
  end

  defp aggregate_target(rows, arm) do
    rows
    |> Enum.flat_map(& &1[arm].target.pairs)
    |> Metrics.target_metrics_from_pairs()
  end

  defp recovery_summary(rows, arm) do
    recoveries = Enum.map(rows, & &1[arm].recovery)
    successes = Enum.count(recoveries, & &1.success)
    rounds = recoveries |> Enum.map(& &1.recovery_round) |> Enum.reject(&is_nil/1)

    %{
      count: length(recoveries),
      success_rate: ratio(successes, length(recoveries)),
      mean_recovery_round: if(rounds == [], do: nil, else: Enum.sum(rounds) / length(rounds)),
      initial_false_leader_rate: rate_values(recoveries, & &1.initial_false_leader)
    }
  end

  defp compute_summary(rows) do
    values = Enum.map(rows, & &1.compute_match)
    available = Enum.filter(values, & &1.available)
    ratios = Enum.map(available, & &1.ratio)

    %{
      available_count: length(available),
      unavailable_count: length(values) - length(available),
      within_10pct_rate:
        if(available == [], do: nil, else: rate_values(available, & &1.within_10pct)),
      mean_ratio: if(ratios == [], do: nil, else: mean(ratios)),
      systematic_under_budget: if(ratios == [], do: nil, else: mean(ratios) < 0.90)
    }
  end

  defp compute_match(target, actual) when target > 0 and actual > 0 do
    ratio = actual / target

    %{
      available: true,
      target_tokens: target,
      actual_tokens: actual,
      ratio: ratio,
      relative_error: abs(ratio - 1.0),
      within_10pct: abs(ratio - 1.0) <= 0.10
    }
  end

  defp compute_match(target, actual) do
    %{
      available: false,
      target_tokens: target,
      actual_tokens: actual,
      ratio: nil,
      relative_error: nil,
      within_10pct: false,
      reason: :provider_token_usage_unavailable
    }
  end

  defp maybe_put_compute_budget(opts, target_tokens) when target_tokens > 0,
    do: Keyword.put(opts, :compute_budget_tokens, target_tokens)

  defp maybe_put_compute_budget(opts, _target_tokens),
    do: Keyword.delete(opts, :compute_budget_tokens)

  defp resource_tokens(resources),
    do: (resources[:input_tokens] || 0) + (resources[:output_tokens] || 0)

  defp rate(rows, fun), do: rate_values(rows, fun)
  defp rate_values([], _fun), do: 0.0
  defp rate_values(values, fun), do: Enum.count(values, fun) / length(values)
  defp ratio(_n, 0), do: 0.0
  defp ratio(n, d), do: n / d
  defp mean(xs), do: Enum.sum(xs) / length(xs)

  defp latency_advantage(nil, _), do: 0.0
  defp latency_advantage(_, nil), do: 0.0
  defp latency_advantage(baseline, structured), do: baseline - structured
end
