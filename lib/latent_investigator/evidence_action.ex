defmodule LatentInvestigator.EvidenceAction do
  @moduledoc "Finite evidence action offered by the current environment."
  alias LatentInvestigator.Util

  @enforce_keys [:id, :kind]
  defstruct [:id, :kind, :cost_units, :availability, :target_ref, :description, metadata: %{}]
  @type t :: %__MODULE__{}

  def new(attrs) do
    %__MODULE__{
      id: Util.string(Util.get(attrs, :id)),
      kind: Util.get(attrs, :kind),
      cost_units: Util.get(attrs, :cost_units, 1),
      availability: Util.get(attrs, :availability, :available),
      target_ref: Util.get(attrs, :target_ref),
      description: Util.string(Util.get(attrs, :description, "")),
      metadata: Util.map(Util.get(attrs, :metadata, %{}))
    }
  end
end
