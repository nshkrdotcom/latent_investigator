defmodule LatentInvestigator.Prompt do
  @moduledoc false
  alias LatentInvestigator.JSON

  def local_judgment(request) do
    """
    You are making one bounded semantic judgment inside a larger investigation.
    Do not infer hidden facts not present in STATE. Follow RUBRIC exactly.

    KIND: #{request.kind}
    STATE:
    #{JSON.encode!(request.state)}

    RUBRIC:
    #{JSON.encode!(request.rubric)}

    Return only the schema-defined object. Keep rationale concise.
    """
  end

  def local_judgment_batch(requests) when is_list(requests) and requests != [] do
    payload = Enum.map(requests, fn request ->
      %{request_id: request.id, kind: request.kind, state: request.state, rubric: request.rubric}
    end)

    """
    You are making multiple bounded semantic judgments inside a larger investigation.
    Each item is independent for scoring purposes even when they share evidence.
    Do not infer hidden facts not present in each item's STATE. Follow each RUBRIC exactly.

    REQUESTS:
    #{JSON.encode!(payload)}

    Return exactly one result per request_id using the schema-defined object. Keep rationales concise.
    """
  end

  def generate(inv, mode, opts \\ []) do
    excluded = Keyword.get(opts, :excluded_families, [])
    rejected_ids = Keyword.get(opts, :rejected_worlds, [])
    rejected = inv.worlds |> Map.take(rejected_ids) |> Map.values() |> Enum.map(&Map.take(Map.from_struct(&1), [:id, :summary, :mechanism_family, :hard_failures, :assumptions, :predictions]))
    """
    You are generating competing causal worlds, not selecting one favorite story.
    Mode: #{mode}
    Round: #{inv.round}
    Avoid mere paraphrase. Preserve hard facts and vary mechanism, actor role, provenance, and information flow.
    Excluded/overused mechanism families: #{inspect(excluded)}
    Requested candidate count: #{Keyword.get(opts, :k_initial, 8)}

    REJECTED WORLDS TO REPAIR (empty unless mode=repair):
    #{JSON.encode!(rejected)}

    ACTORS:
    #{JSON.encode!(Map.values(inv.actors))}

    VISIBLE OBSERVATIONS:
    #{JSON.encode!(LatentInvestigator.Investigation.observations(inv))}

    CURRENT WORLDS:
    #{JSON.encode!(Enum.map(LatentInvestigator.Investigation.alive_worlds(inv), &Map.take(Map.from_struct(&1), [:id, :summary, :mechanism_family, :assumptions, :predictions, :falsifiers])))}

    Return only the requested structured object.
    """
  end

  def attack(inv, worlds) do
    """
    Attack the supplied leading worlds. Identify weak assumptions and generate materially different alternatives that preserve all explicit hard facts.
    Do not silently repair an existing world: alternatives must be separate descendants.

    VISIBLE OBSERVATIONS:
    #{JSON.encode!(LatentInvestigator.Investigation.observations(inv))}

    WORLDS TO ATTACK:
    #{JSON.encode!(worlds)}

    Return only the requested structured object.
    """
  end

  def baseline(state, stage \\ :analyze) do
    """
    You are the monolithic investigator baseline. Stage: #{stage}.
    Maintain multiple causal explanations. Treat provenance and copied evidence explicitly. Do not force a unique conclusion when the visible evidence does not identify one.
    Answer the public targets with supported/rejected/unresolved and choose a next evidence action if one materially separates explanations.

    CASE STATE:
    #{JSON.encode!(state)}

    Return only the requested structured object.
    """
  end
end
