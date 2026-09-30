defmodule LatentInvestigator.RunnerSmokeTest do
  use ExUnit.Case, async: true

  test "pure oracle smoke executes a complete investigation without model credentials" do
    assert {:ok, result} = LatentInvestigator.Experiment.Smoke.run(seed: 7, round_budget: 2)
    assert result.investigation.round <= 2
    assert map_size(result.investigation.worlds) >= 2
    assert is_map(result.report.target_statuses)
    assert result.report.resource_summary.local_judgments > 0
  end
end
