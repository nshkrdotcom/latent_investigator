defmodule LatentInvestigator.Actor do
  @moduledoc "Actor record. Hidden simulator fields are stripped before investigator admission."
  alias LatentInvestigator.Util

  @enforce_keys [:id]
  defstruct [:id, public_profile: %{}, capabilities: [], known_facts: [], goals: [], channel_access: [], relationships: []]
  @type t :: %__MODULE__{}

  def new(attrs) do
    %__MODULE__{
      id: Util.string(Util.get(attrs, :id)),
      public_profile: Util.map(Util.get(attrs, :public_profile, %{})),
      capabilities: Util.list(Util.get(attrs, :capabilities, [])),
      known_facts: Util.list(Util.get(attrs, :known_facts, [])),
      goals: Util.list(Util.get(attrs, :goals, [])),
      channel_access: Util.list(Util.get(attrs, :channel_access, [])),
      relationships: Util.list(Util.get(attrs, :relationships, []))
    }
  end

  def public(%__MODULE__{} = actor), do: %{actor | known_facts: [], goals: []}
end
