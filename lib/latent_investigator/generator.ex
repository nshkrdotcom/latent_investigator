defmodule LatentInvestigator.Generator do
  @moduledoc "Candidate-world generation boundary."
  alias LatentInvestigator.Investigation

  defmodule Context do
    @moduledoc false
    defstruct [:client, :model, :provider, config: %{}, metadata: %{}]
    @type t :: %__MODULE__{}
  end

  @callback initial(Context.t(), Investigation.t(), keyword()) :: {:ok, [LatentInvestigator.World.t()]} | {:error, term()}
  @callback attack(Context.t(), Investigation.t(), [LatentInvestigator.World.t()], keyword()) :: {:ok, [LatentInvestigator.World.t()]} | {:error, term()}
  @callback repair(Context.t(), Investigation.t(), [LatentInvestigator.World.t()], keyword()) :: {:ok, [LatentInvestigator.World.t()]} | {:error, term()}
end
