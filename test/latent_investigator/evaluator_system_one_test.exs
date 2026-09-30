defmodule LatentInvestigator.EvaluatorSystemOneTest do
  use ExUnit.Case, async: false
  alias LatentInvestigator.Evaluator.{Context, JudgmentRequest}
  alias LatentInvestigator.Evaluator.SystemOne

  test "maps System One score answers onto the fixed compatibility ordinal" do
    client = SystemOneSDK.Test.client()
    request = JudgmentRequest.new(%{id: "j-score", kind: :observation_compatibility, state: %{world: "w", evidence: "e"}, rubric: %{}, world_id: "w", subject_refs: ["obs1"], observation_id: "obs1", round: 0})
    client = SystemOneSDK.Test.stub(client, %{"j-score" => {:score, 3.0, 0.9}})

    assert {:ok, judgment} = SystemOne.judge(%Context{client: client, provider: :system_one}, request)
    assert judgment.value == :supports
    assert judgment.ordinal_weight == 1
    assert judgment.provider_confidence == 0.9

    assert :ok = SystemOneSDK.Test.verify!(client)
    assert :ok = SystemOneSDK.Test.close(client)
  end
end
