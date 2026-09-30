defmodule LatentInvestigator.Observation do
  @moduledoc "Visible evidence record."
  alias LatentInvestigator.Util

  @enforce_keys [:id, :surface]
  defstruct [
    :id,
    :round,
    :timestamp,
    :surface,
    :observation_type,
    :claimed_source,
    :authenticated_source,
    :provenance_ref,
    :access_level,
    metadata: %{}
  ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    %__MODULE__{
      id: Util.string(Util.get(attrs, :id)),
      round: Util.get(attrs, :round, 0),
      timestamp: Util.get(attrs, :timestamp),
      surface: Util.string(Util.get(attrs, :surface, "")),
      observation_type: Util.get(attrs, :observation_type, :text),
      claimed_source: Util.get(attrs, :claimed_source),
      authenticated_source: Util.get(attrs, :authenticated_source),
      provenance_ref: Util.get(attrs, :provenance_ref),
      access_level: Util.get(attrs, :access_level, :public),
      metadata: Util.map(Util.get(attrs, :metadata, %{}))
    }
  end
end
