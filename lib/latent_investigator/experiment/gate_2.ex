defmodule LatentInvestigator.Experiment.Gate2 do
  @moduledoc "Evaluator substitution diagnostic: oracle, frontier, cheap-general and System One on frozen candidate worlds."

  alias LatentInvestigator.{Aggregator, Config, Evaluator, Investigation, LocalJudgments, Report}
  alias LatentInvestigator.Evaluator.Context
  alias LatentInvestigator.Generator.Context, as: GeneratorContext
  alias LatentInvestigator.Simulator.StrategicNetwork
  alias LatentInvestigator.Experiment.Metrics

  def run(opts \\ []) do
    frontier = Keyword.get(opts, :frontier_client) || Config.inference_client!(:frontier)
    cheap = Keyword.get(opts, :cheap_client) || Config.inference_client!(:cheap)
    system_one = Keyword.get(opts, :system_one_client) || Config.system_one_client!()
    seed = Keyword.get(opts, :seed, 1)
    profile = Keyword.get(opts, :profile, :medium)
    case_class = Keyword.get(opts, :case_class, :transition)
    access = Keyword.get(opts, :access_regime, :public)
    batch_size = Keyword.get(opts, :judgment_batch_size, 16)

    {:ok, env} = StrategicNetwork.new(seed, profile, case_class, access)

    base_inv =
      Investigation.new(
        actors: StrategicNetwork.public_actors(env),
        observations: StrategicNetwork.initial_observations(env),
        provenance: StrategicNetwork.known_provenance(env)
      )

    {:ok, worlds} =
      LatentInvestigator.Generator.Inference.initial(
        %GeneratorContext{client: frontier, provider: :frontier},
        base_inv,
        k_initial: Keyword.get(opts, :k_initial, 8)
      )

    frozen = Investigation.add_worlds(base_inv, worlds)

    arms = [
      oracle:
        {LatentInvestigator.Evaluator.Oracle,
         %Context{provider: :oracle, model: "oracle", oracle_fun: &StrategicNetwork.oracle_judgment(env, &1)}},
      frontier:
        {LatentInvestigator.Evaluator.Inference,
         %Context{client: frontier, provider: :frontier, config: %{batch_size: batch_size}}},
      cheap_general:
        {LatentInvestigator.Evaluator.Inference,
         %Context{client: cheap, provider: :cheap_general, config: %{batch_size: batch_size}}},
      system_one:
        {LatentInvestigator.Evaluator.SystemOne,
         %Context{client: system_one, provider: :system_one}}
    ]

    results = Map.new(arms, fn {name, {module, context}} -> {name, score_arm(frozen, env, module, context)} end)
    oracle_judgments = get_in(results, [:oracle, :judgments]) || %{}

    agreement =
      for arm <- [:frontier, :cheap_general, :system_one], into: %{} do
        {arm, agreement(oracle_judgments, get_in(results, [arm, :judgments]) || %{})}
      end

    stripped = Map.new(results, fn {arm, result} -> {arm, Map.delete(result, :judgments)} end)

    {:ok,
     %{
       gate: 2,
       seed: seed,
       profile: profile,
       case_class: case_class,
       frozen_candidate_count: length(worlds),
       results: stripped,
       local_judgment_agreement_to_oracle: agreement
     }}
  end

  defp score_arm(inv, env, module, context) do
    requests = LocalJudgments.compatibility_requests(inv)

    case Evaluator.judge_many(module, context, requests) do
      {:ok, judgments} ->
        scored = inv |> Investigation.add_judgments(judgments) |> Aggregator.run()
        report = Report.build(scored, StrategicNetwork.task_targets(env))

        %{
          status: :ok,
          metrics: Metrics.target_metrics(report, StrategicNetwork.evaluation_targets(env)),
          resolution_balanced_accuracy: Metrics.resolution_balanced_accuracy(report, StrategicNetwork.evaluation_targets(env)),
          resources: report.resource_summary,
          report: report,
          judgments: Map.new(judgments, &{&1.id, %{kind: &1.kind, value: &1.value}})
        }

      {:error, reason} ->
        %{status: :error, reason: inspect(reason), judgments: %{}}
    end
  end

  defp agreement(left, right) do
    common = Map.keys(left) |> MapSet.new() |> MapSet.intersection(Map.keys(right) |> MapSet.new()) |> MapSet.to_list()
    overall = exact_agreement(common, left, right)

    by_kind =
      common
      |> Enum.group_by(fn id -> get_in(left, [id, :kind]) end)
      |> Map.new(fn {kind, ids} -> {kind, exact_agreement(ids, left, right)} end)

    %{count: length(common), exact_agreement: overall.exact_agreement, by_kind: by_kind}
  end

  defp exact_agreement(ids, left, right) do
    matches = Enum.count(ids, fn id -> get_in(left, [id, :value]) == get_in(right, [id, :value]) end)
    %{count: length(ids), exact_agreement: if(ids == [], do: 0.0, else: matches / length(ids))}
  end
end
