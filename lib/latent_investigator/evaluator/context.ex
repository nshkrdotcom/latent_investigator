defmodule LatentInvestigator.Evaluator.Context do
  @moduledoc "Provider-specific runtime context kept outside authoritative investigation state."
  defstruct [:client, :model, :provider, :oracle_fun, config: %{}, metadata: %{}]
  @type t :: %__MODULE__{}
end
