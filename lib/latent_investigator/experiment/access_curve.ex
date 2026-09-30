defmodule LatentInvestigator.Experiment.AccessCurve do
  @moduledoc "Runs the same simulator seed across public/limited/operator/oracle evidence regimes."
  alias LatentInvestigator.Simulator.StrategicNetwork

  def environments(seed, profile \\ :medium, case_class \\ :transition) do
    for regime <- [:public, :limited, :operator, :oracle], into: %{} do
      {:ok, env} = StrategicNetwork.new(seed, profile, case_class, regime)
      {regime, env}
    end
  end
end
