defmodule LatentInvestigator.Schema do
  @moduledoc false

  @compatibility_values ~w(strongly_against against neutral supports strongly_supports)
  @source_values ~w(same_source likely_related unclear likely_independent independent)

  def local_judgment(kind)
      when kind in [
             :observation_compatibility,
             :actor_behavior_plausibility,
             :mechanism_plausibility
           ] do
    object(
      %{
        "value" => %{"type" => "string", "enum" => @compatibility_values},
        "confidence" => nullable_number(),
        "rationale" => %{"type" => "string"}
      },
      ~w(value confidence rationale)
    )
  end

  def local_judgment(:source_dependence) do
    object(
      %{
        "value" => %{"type" => "string", "enum" => @source_values},
        "confidence" => nullable_number(),
        "rationale" => %{"type" => "string"}
      },
      ~w(value confidence rationale)
    )
  end

  def local_judgment(kind) when kind in [:semantic_entailment, :textual_contradiction] do
    object(
      %{
        "value" => %{"type" => "string", "enum" => ["yes", "no", "unclear"]},
        "confidence" => nullable_number(),
        "rationale" => %{"type" => "string"}
      },
      ~w(value confidence rationale)
    )
  end

  def local_judgment_batch(kind) do
    result =
      object(
        %{
          "request_id" => string(),
          "value" => local_judgment(kind)["properties"]["value"],
          "confidence" => nullable_number(),
          "rationale" => string()
        },
        ~w(request_id value confidence rationale)
      )

    object(%{"results" => array(result)}, ["results"])
  end

  def candidate_world do
    object(
      %{
        "client_id" => %{"type" => "string"},
        "summary" => %{"type" => "string"},
        "mechanism_family" => %{"type" => "string"},
        "actor_roles" =>
          array(object(%{"actor_id" => string(), "role" => string()}, ~w(actor_id role))),
        "actor_knowledge" =>
          array(
            object(
              %{
                "actor_id" => string(),
                "fact_id" => string(),
                "status" => %{
                  "type" => "string",
                  "enum" => ~w(knows may_know does_not_know unknown)
                },
                "by_time" => %{"anyOf" => [string(), %{"type" => "null"}]}
              },
              ~w(actor_id fact_id status by_time)
            )
          ),
        "causal_links" =>
          array(
            object(
              %{"from_ref" => string(), "to_ref" => string(), "relation" => string()},
              ~w(from_ref to_ref relation)
            )
          ),
        "source_hypotheses" =>
          array(
            object(
              %{
                "observation_id" => string(),
                "source_actor_id" => %{"anyOf" => [string(), %{"type" => "null"}]},
                "mechanism" => string(),
                "claimed_source_status" => string()
              },
              ~w(observation_id source_actor_id mechanism claimed_source_status)
            )
          ),
        "assumptions" => array(string()),
        "predictions" => array(string()),
        "falsifiers" => array(string())
      },
      ~w(client_id summary mechanism_family actor_roles actor_knowledge causal_links source_hypotheses assumptions predictions falsifiers)
    )
  end

  def candidate_worlds, do: object(%{"worlds" => array(candidate_world())}, ["worlds"])

  def attack do
    weakness =
      object(
        %{"world_id" => string(), "issue" => string(), "evidence_refs" => array(string())},
        ~w(world_id issue evidence_refs)
      )

    object(
      %{"weaknesses" => array(weakness), "alternative_worlds" => array(candidate_world())},
      ~w(weaknesses alternative_worlds)
    )
  end

  def baseline_round do
    world =
      Map.put(
        candidate_world(),
        "properties",
        Map.put(candidate_world()["properties"], "relative_support", nullable_number())
      )

    world = Map.put(world, "required", candidate_world()["required"] ++ ["relative_support"])

    target =
      object(
        %{
          "target_id" => string(),
          "status" => %{"type" => "string", "enum" => ~w(supported rejected unresolved)}
        },
        ~w(target_id status)
      )

    rejected =
      object(
        %{"summary" => string(), "reason" => string(), "evidence_refs" => array(string())},
        ~w(summary reason evidence_refs)
      )

    object(
      %{
        "worlds" => array(world),
        "target_statuses" => array(target),
        "rejected_explanations" => array(rejected),
        "provenance_concerns" => array(string()),
        "unresolved_questions" => array(string()),
        "non_identifiable_claims" => array(string()),
        "next_action_id" => %{"anyOf" => [string(), %{"type" => "null"}]},
        "conclusion" => string()
      },
      ~w(worlds target_statuses rejected_explanations provenance_concerns unresolved_questions non_identifiable_claims next_action_id conclusion)
    )
  end

  defp object(properties, required),
    do: %{
      "type" => "object",
      "additionalProperties" => false,
      "properties" => properties,
      "required" => required
    }

  defp array(items), do: %{"type" => "array", "items" => items}
  defp string, do: %{"type" => "string"}

  defp nullable_number,
    do: %{"anyOf" => [%{"type" => "number", "minimum" => 0, "maximum" => 1}, %{"type" => "null"}]}
end
