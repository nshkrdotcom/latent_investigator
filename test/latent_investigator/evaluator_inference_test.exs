defmodule LatentInvestigator.EvaluatorInferenceTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}
  alias LatentInvestigator.Evaluator.Inference, as: InferenceEvaluator

  test "normalizes strict structured mock output into a local judgment" do
    client =
      Inference.Client.new!(
        adapter: Inference.Adapters.Mock,
        provider: :mock,
        model: "mock",
        adapter_opts: [
          response_object: %{"value" => "supports", "confidence" => 0.8, "rationale" => "fits"}
        ]
      )

    request =
      JudgmentRequest.new(%{
        id: "j1",
        kind: :observation_compatibility,
        state: %{x: 1},
        rubric: %{},
        world_id: "w1",
        subject_refs: ["obs1"],
        observation_id: "obs1",
        round: 0
      })

    assert {:ok, judgment} =
             InferenceEvaluator.judge(%Context{client: client, provider: :mock}, request)

    assert judgment.value == :supports
    assert judgment.ordinal_weight == 1
    assert judgment.provider_confidence == 0.8
  end
end

defmodule LatentInvestigator.EvaluatorInferenceBatchTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}
  alias LatentInvestigator.Evaluator.Inference, as: InferenceEvaluator

  test "batches same-evidence judgments and preserves request identity" do
    client =
      Inference.Client.new!(
        adapter: Inference.Adapters.Mock,
        provider: :mock,
        model: "mock",
        adapter_opts: [
          response_object: %{
            "results" => [
              %{
                "request_id" => "j1",
                "value" => "supports",
                "confidence" => 0.8,
                "rationale" => "fits"
              },
              %{
                "request_id" => "j2",
                "value" => "against",
                "confidence" => 0.7,
                "rationale" => "does not fit"
              }
            ]
          }
        ]
      )

    requests = [
      JudgmentRequest.new(%{
        id: "j1",
        kind: :observation_compatibility,
        state: %{world: "w1"},
        rubric: %{},
        world_id: "w1",
        subject_refs: ["obs1"],
        observation_id: "obs1",
        round: 0,
        metadata: %{evidence_unit_id: "e1"}
      }),
      JudgmentRequest.new(%{
        id: "j2",
        kind: :observation_compatibility,
        state: %{world: "w2"},
        rubric: %{},
        world_id: "w2",
        subject_refs: ["obs1"],
        observation_id: "obs1",
        round: 0,
        metadata: %{evidence_unit_id: "e1"}
      })
    ]

    assert {:ok, [j1, j2]} =
             InferenceEvaluator.judge_many(
               %Context{client: client, provider: :frontier, config: %{batch_size: 8}},
               requests
             )

    assert {j1.id, j1.value, j1.ordinal_weight} == {"j1", :supports, 1}
    assert {j2.id, j2.value, j2.ordinal_weight} == {"j2", :against, -1}
    assert j1.batch_id == j2.batch_id
    assert j1.metadata.transport_call_id == j2.metadata.transport_call_id
    assert j1.provider == :mock

    report =
      LatentInvestigator.Investigation.new()
      |> LatentInvestigator.Investigation.add_judgments([j1, j2])
      |> LatentInvestigator.Report.build()

    assert report.resource_summary.local_judgments == 2
    assert report.resource_summary.local_transport_calls == 1
    assert report.resource_summary.frontier_calls == 1
  end
end
