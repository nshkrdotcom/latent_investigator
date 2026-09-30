defmodule LatentInvestigator.BaselineMonolithicTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.Baseline.Monolithic
  alias LatentInvestigator.Simulator.StrategicNetwork

  test "single-call baseline returns normalized target statuses and candidate worlds" do
    object = %{
      "worlds" => [%{
        "client_id" => "b0-world",
        "summary" => "baseline world",
        "mechanism_family" => "external_leak_then_amplification",
        "actor_roles" => [], "actor_knowledge" => [], "causal_links" => [], "source_hypotheses" => [],
        "assumptions" => [], "predictions" => [], "falsifiers" => [], "relative_support" => 0.6
      }],
      "target_statuses" => [%{"target_id" => "target_source", "status" => "unresolved"}, %{"target_id" => "target_mechanism", "status" => "unresolved"}],
      "rejected_explanations" => [], "provenance_concerns" => [], "unresolved_questions" => [], "non_identifiable_claims" => [],
      "next_action_id" => nil, "conclusion" => "not enough evidence"
    }
    client = Inference.Client.new!(adapter: Inference.Adapters.Mock, provider: :mock, model: "mock", adapter_opts: [response_object: object])
    {:ok, env} = StrategicNetwork.new(1, :smoke, :transition, :public)
    assert {:ok, result} = Monolithic.run(env, StrategicNetwork, client, :single, round_budget: 1)
    assert result.report.target_statuses["target_source"] == "unresolved"
    assert hd(result.worlds).id == "b0-world"
  end
end
