defmodule LatentInvestigator.Simulator do
  @moduledoc "Controlled environment contract for known-hidden-state experiments."

  @callback new(integer(), atom(), atom(), atom()) :: {:ok, term()} | {:error, term()}
  @callback public_actors(term()) :: list()
  @callback initial_observations(term()) :: list()
  @callback known_provenance(term()) :: LatentInvestigator.Provenance.t()
  @callback available_actions(term(), LatentInvestigator.Investigation.t()) :: list()
  @callback execute(term(), LatentInvestigator.EvidenceAction.t()) ::
              {:ok, term(), list()} | {:error, term()}
  @callback predict(
              LatentInvestigator.World.t(),
              LatentInvestigator.EvidenceAction.t(),
              keyword()
            ) :: {:ok, term()} | :unsupported
  @callback hidden_truth(term()) :: term()
  @callback task_targets(term()) :: list()
  @callback evaluation_targets(term()) :: list()
  @callback match_world(term(), LatentInvestigator.World.t()) :: map()
end
