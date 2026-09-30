defmodule LatentInvestigator.Evaluator.JudgmentRequest do
  @moduledoc "Deterministic bounded semantic request."
  alias LatentInvestigator.{ID, Util}

  defstruct [
    :id,
    :kind,
    :state,
    :rubric,
    :world_id,
    :subject_refs,
    :observation_id,
    :round,
    metadata: %{}
  ]

  @type t :: %__MODULE__{}

  def new(attrs) do
    kind = Util.get(attrs, :kind)
    world_id = Util.get(attrs, :world_id)
    refs = Util.list(Util.get(attrs, :subject_refs, []))
    round = Util.get(attrs, :round, 0)
    id = Util.get(attrs, :id, ID.stable("judge", {kind, world_id, refs, Util.get(attrs, :state)}))

    %__MODULE__{
      id: id,
      kind: kind,
      state: Util.map(Util.get(attrs, :state, %{})),
      rubric: Util.get(attrs, :rubric, %{}),
      world_id: world_id,
      subject_refs: refs,
      observation_id: Util.get(attrs, :observation_id),
      round: round,
      metadata: Util.map(Util.get(attrs, :metadata, %{}))
    }
  end
end
