defmodule LatentInvestigator.Judgment do
  @moduledoc "Immutable normalized local semantic judgment."
  alias LatentInvestigator.Util

  @compatibility %{
    strongly_against: -2,
    against: -1,
    neutral: 0,
    supports: 1,
    strongly_supports: 2
  }

  defstruct [
    :id, :kind, :subject_ref, :world_id, :observation_id, :value, :ordinal_weight,
    :provider, :model, :provider_confidence, :distribution, :latency_ms, :usage,
    :cost, :round, :request_id, :batch_id, :batch_position, metadata: %{}
  ]
  @type t :: %__MODULE__{}

  def compatibility_weight(value) when is_binary(value) do
    case value do
      "strongly_against" -> -2
      "against" -> -1
      "neutral" -> 0
      "supports" -> 1
      "strongly_supports" -> 2
      _ -> nil
    end
  end
  def compatibility_weight(value) when is_atom(value), do: Map.get(@compatibility, value)
  def compatibility_weight(_), do: nil

  def new(attrs) do
    value = Util.get(attrs, :value)
    kind = Util.get(attrs, :kind)
    weight = Util.get(attrs, :ordinal_weight, if(kind in [:observation_compatibility, "observation_compatibility"], do: compatibility_weight(value)))

    %__MODULE__{
      id: Util.string(Util.get(attrs, :id)),
      kind: kind,
      subject_ref: Util.get(attrs, :subject_ref),
      world_id: Util.get(attrs, :world_id),
      observation_id: Util.get(attrs, :observation_id),
      value: value,
      ordinal_weight: weight,
      provider: Util.get(attrs, :provider),
      model: Util.get(attrs, :model),
      provider_confidence: Util.get(attrs, :provider_confidence),
      distribution: Util.get(attrs, :distribution),
      latency_ms: Util.get(attrs, :latency_ms),
      usage: Util.get(attrs, :usage),
      cost: Util.get(attrs, :cost),
      round: Util.get(attrs, :round, 0),
      request_id: Util.get(attrs, :request_id),
      batch_id: Util.get(attrs, :batch_id),
      batch_position: Util.get(attrs, :batch_position),
      metadata: Util.map(Util.get(attrs, :metadata, %{}))
    }
  end
end
