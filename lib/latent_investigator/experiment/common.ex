defmodule LatentInvestigator.Experiment.Common do
  @moduledoc false
  alias LatentInvestigator.Experiment.Metrics

  def score_structured(result, simulator) do
    targets = simulator.evaluation_targets(result.environment)
    truth = simulator.hidden_truth(result.environment)
    %{
      target: Metrics.target_metrics(result.report, targets),
      resolution_balanced_accuracy: Metrics.resolution_balanced_accuracy(result.report, targets),
      true_world_retention: Metrics.true_world_retention(Map.values(result.investigation.worlds), truth, simulator),
      recovery: Metrics.structured_recovery(result, truth, simulator),
      resources: result.report.resource_summary
    }
  end

  def score_baseline(result, simulator) do
    targets = simulator.evaluation_targets(result.environment)
    truth = simulator.hidden_truth(result.environment)
    %{
      target: Metrics.target_metrics(result.report, targets),
      resolution_balanced_accuracy: Metrics.resolution_balanced_accuracy(result.report, targets),
      true_world_retention: Metrics.true_world_retention(result.worlds, truth, simulator),
      recovery: Metrics.baseline_recovery(result, truth, simulator),
      resources: result.usage
    }
  end
end
