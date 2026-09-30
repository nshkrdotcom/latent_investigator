defmodule LatentInvestigator.ArtifactReplayTest do
  use ExUnit.Case, async: true

  test "persisted normalized artifacts hash-verify and reload without provider calls" do
    root =
      Path.join(System.tmp_dir!(), "latent-investigator-#{System.unique_integer([:positive])}")

    assert {:ok, result} =
             LatentInvestigator.Experiment.Smoke.run(
               seed: 9,
               round_budget: 1,
               persist: true,
               artifact_root: root
             )

    run_dir = result.artifacts.run_dir
    assert :ok = LatentInvestigator.Replay.verify(run_dir)
    assert {:ok, replay} = LatentInvestigator.Replay.load(run_dir)
    assert replay.manifest["seed"] == 9
    assert is_map(replay.report)
    assert is_map(replay.evaluation)
    assert replay.evaluation["hidden_truth"]["id"]
    File.rm_rf!(root)
  end
end
