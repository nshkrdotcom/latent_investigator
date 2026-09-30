defmodule LatentInvestigator.Simulator.StrategicNetwork do
  @moduledoc """
  Deterministic strategic-network laboratory with partial actor knowledge, copied evidence,
  source ambiguity, spoofing and access-controlled discriminating evidence.

  It is deliberately procedural rather than an autonomous LLM society: hidden truth is code-owned.
  """
  @behaviour LatentInvestigator.Simulator

  alias LatentInvestigator.{Actor, EvidenceAction, Observation, Provenance, Util, World}

  defmodule Env do
    @moduledoc false
    defstruct [
      :seed,
      :profile,
      :case_class,
      :access_regime,
      :true_world,
      :decoy_worlds,
      :anchor_observation_id,
      :true_source_actor_id,
      :decoy_source_actor_id,
      actors: [],
      observations: [],
      hidden_observation_facts: %{},
      actions: [],
      action_results: %{},
      targets: [],
      round: 0,
      executed_actions: MapSet.new()
    ]
  end

  @profiles %{
    smoke: %{actors: 5, observations: 20},
    small: %{actors: 20, observations: 150},
    medium: %{actors: 40, observations: 400},
    large: %{actors: 80, observations: 1000}
  }
  @case_classes [:resolvable, :non_identifiable, :transition]
  @access_regimes [:public, :limited, :operator, :oracle]

  @impl true
  def new(seed, profile, case_class, access_regime)
      when is_integer(seed) and profile in [:smoke, :small, :medium, :large] and
             case_class in @case_classes and access_regime in @access_regimes do
    shape = Map.fetch!(@profiles, profile)
    actors = build_actors(shape.actors, seed)
    true_source = actor_id(rem(abs(seed), shape.actors) + 1)
    decoy_source = actor_id(rem(abs(seed) + 2, shape.actors) + 1)
    anchor = "obs_001"

    {observations, hidden_facts} =
      build_observations(
        shape.observations,
        shape.actors,
        seed,
        true_source,
        decoy_source,
        case_class
      )

    {true_world, decoys} =
      build_worlds(seed, case_class, anchor, true_source, decoy_source, observations)

    {actions, action_results} =
      build_actions(case_class, access_regime, anchor, true_source, seed)

    targets = build_targets(case_class, anchor, true_source, true_world.mechanism_family)

    {:ok,
     %Env{
       seed: seed,
       profile: profile,
       case_class: case_class,
       access_regime: access_regime,
       actors: actors,
       observations: observations,
       hidden_observation_facts: hidden_facts,
       true_world: true_world,
       decoy_worlds: decoys,
       anchor_observation_id: anchor,
       true_source_actor_id: true_source,
       decoy_source_actor_id: decoy_source,
       actions: actions,
       action_results: action_results,
       targets: targets
     }}
  end

  def new(seed, profile, case_class, access_regime),
    do: {:error, {:invalid_simulator_config, seed, profile, case_class, access_regime}}

  @impl true
  def public_actors(%Env{} = env) do
    Enum.map(env.actors, fn actor ->
      case env.access_regime do
        :oracle -> actor
        :operator -> %{Actor.public(actor) | channel_access: actor.channel_access}
        _ -> Actor.public(actor)
      end
    end)
  end

  @impl true
  def initial_observations(%Env{} = env),
    do: Enum.map(env.observations, &mask_observation(&1, env.access_regime))

  @impl true
  def known_provenance(%Env{} = env) do
    graph =
      env
      |> initial_observations()
      |> Enum.reduce(Provenance.new(), fn obs, graph ->
        ref = obs.provenance_ref || "observation:#{obs.id}"
        graph |> Provenance.put_node(ref, %{observation_id: obs.id})
      end)

    if MapSet.member?(env.executed_actions, "act_provenance") do
      graph
      |> Provenance.put_edge("root_005", "root_009", :copied_from, %{
        revealed_by: "act_provenance"
      })
    else
      graph
    end
  end

  @impl true
  def available_actions(%Env{} = env, _investigation) do
    Enum.reject(env.actions, fn action ->
      MapSet.member?(env.executed_actions, action.id) or
        not access_allows?(env.access_regime, action.availability)
    end)
  end

  @impl true
  def execute(%Env{} = env, %EvidenceAction{id: id}) do
    cond do
      MapSet.member?(env.executed_actions, id) ->
        {:error, {:action_already_executed, id}}

      not Enum.any?(env.actions, &(&1.id == id)) ->
        {:error, {:unknown_action, id}}

      true ->
        observations =
          Map.get(env.action_results, id, [])
          |> Enum.map(&mask_observation(&1, env.access_regime))

        {:ok,
         %{env | round: env.round + 1, executed_actions: MapSet.put(env.executed_actions, id)},
         observations}
    end
  end

  @impl true
  def predict(
        %World{} = world,
        %EvidenceAction{kind: :authenticate_source, target_ref: observation_id},
        _opts
      ) do
    {:ok, {:source, World.source_actor(world, observation_id) || :unknown}}
  end

  def predict(
        %World{} = world,
        %EvidenceAction{kind: :reveal_actor_knowledge, target_ref: {actor_id, fact_id}},
        _opts
      ) do
    {:ok, {:knowledge, World.actor_knowledge_status(world, actor_id, fact_id) || :unknown}}
  end

  def predict(%World{} = world, %EvidenceAction{kind: :reveal_provenance}, _opts) do
    source =
      world.source_hypotheses
      |> Enum.map(&Util.get(&1, :source_actor_id))
      |> Enum.reject(&is_nil/1)
      |> Enum.sort()

    {:ok, {:source_pattern, source}}
  end

  def predict(%World{} = world, %EvidenceAction{kind: :reveal_channel_log}, _opts),
    do: {:ok, {:mechanism, world.mechanism_family}}

  def predict(_world, _action, _opts), do: :unsupported

  @impl true
  def hidden_truth(%Env{} = env), do: env.true_world

  def oracle_candidates(%Env{} = env), do: [env.true_world | env.decoy_worlds]

  @impl true
  def task_targets(%Env{} = env) do
    Enum.map(env.targets, &Map.take(&1, [:id, :proposition, :query]))
  end

  @impl true
  def evaluation_targets(%Env{} = env) do
    Enum.map(env.targets, fn target ->
      Map.put(target, :expected_status, expected_status(env, target))
    end)
  end

  @impl true
  def match_world(%World{} = truth, %World{} = candidate) do
    source_truth = World.source_actor(truth, "obs_001")
    source_candidate = World.source_actor(candidate, "obs_001")
    mechanism_match = truth.mechanism_family == candidate.mechanism_family
    source_match = if source_truth == source_candidate, do: 1.0, else: 0.0
    role_truth = Map.new(truth.actor_roles, &{Util.get(&1, :actor_id), Util.get(&1, :role)})

    role_candidate =
      Map.new(candidate.actor_roles, &{Util.get(&1, :actor_id), Util.get(&1, :role)})

    overlap =
      if map_size(role_truth) == 0,
        do: 1.0,
        else:
          Enum.count(role_truth, fn {k, v} -> Map.get(role_candidate, k) == v end) /
            map_size(role_truth)

    %{
      compatible: mechanism_match and source_match == 1.0,
      mechanism_match: mechanism_match,
      actor_assignment_match: overlap,
      source_assignment_match: source_match
    }
  end

  def match_world(%Env{} = env, candidate), do: match_world(env.true_world, candidate)

  def oracle_judgment(%Env{} = env, request) do
    world = world_from_request(request)
    obs_ids = request.subject_refs
    weights = Enum.map(obs_ids, &oracle_weight(env, world, &1))

    weight =
      if weights == [], do: 0, else: round(Enum.sum(weights) / length(weights)) |> clamp(-2, 2)

    %{value: value_for_weight(weight), ordinal_weight: weight, confidence: 1.0}
  end

  def profile_shape(profile), do: Map.fetch!(@profiles, profile)

  defp build_actors(count, seed) do
    Enum.map(1..count, fn i ->
      Actor.new(%{
        id: actor_id(i),
        public_profile: %{label: "Network actor #{i}", cohort: rem(i + abs(seed), 3)},
        capabilities: [:read, :publish],
        known_facts: hidden_facts_for_actor(i, seed),
        goals: hidden_goals_for_actor(i, seed),
        channel_access:
          if(rem(i, 4) == 0, do: [:shared_channel, :amplification], else: [:shared_channel]),
        relationships: []
      })
    end)
  end

  defp hidden_facts_for_actor(i, seed) do
    base = if rem(i + abs(seed), 3) == 0, do: ["fact_origin"], else: []
    if rem(i, 4) == 0, do: ["fact_channel" | base], else: base
  end

  defp hidden_goals_for_actor(i, seed) do
    case rem(i + abs(seed), 4) do
      0 -> ["protect_target"]
      1 -> ["preserve_secrecy"]
      2 -> ["shape_beliefs"]
      _ -> ["avoid_involvement"]
    end
  end

  defp build_observations(count, actor_count, seed, true_source, decoy_source, case_class) do
    Enum.map_reduce(1..count, %{}, fn i, hidden ->
      id = obs_id(i)
      copied_from = if i > 2 and rem(i, 7) == 0, do: i - 2, else: nil
      provenance_ref = if copied_from, do: "root_#{pad(copied_from)}", else: "root_#{pad(i)}"

      claimed =
        if rem(i + seed, 5) == 0,
          do: decoy_source,
          else: actor_id(rem(i + abs(seed), actor_count) + 1)

      bias = bias_for(i, case_class)
      surface = surface_for(i, copied_from, true_source, decoy_source, bias, seed, case_class)
      public_authenticated? = case_class == :resolvable and i == 1
      authenticated_source = if public_authenticated?, do: true_source, else: nil

      metadata = %{
        explicit_copy: not is_nil(copied_from),
        public_authenticated: public_authenticated?,
        authenticates_mechanism:
          if(case_class == :resolvable and i == 2, do: true_mechanism(case_class), else: nil)
      }

      obs =
        Observation.new(%{
          id: id,
          round: 0,
          timestamp: timestamp(i),
          surface: surface,
          observation_type: :channel_event,
          claimed_source: claimed,
          authenticated_source: authenticated_source,
          provenance_ref: provenance_ref,
          access_level: :public,
          metadata: metadata
        })

      facts = %{
        true_source: if(i == 1, do: true_source, else: nil),
        evidence_bias: bias,
        true_mechanism: true_mechanism(case_class),
        copied_from: copied_from
      }

      {obs, Map.put(hidden, id, facts)}
    end)
  end

  defp build_worlds(seed, case_class, anchor, true_source, decoy_source, observations) do
    mechanism = true_mechanism(case_class)
    role = if(case_class == :non_identifiable, do: "protective_sender", else: "informed_sender")

    true_world =
      World.from_candidate(
        %{
          client_id: "world_true_#{seed}",
          summary: "Hidden generating path with #{mechanism} through #{true_source}.",
          mechanism_family: mechanism,
          actor_roles: [%{actor_id: true_source, role: role}],
          actor_knowledge: [
            %{
              actor_id: true_source,
              fact_id: "fact_origin",
              status: "knows",
              by_time: timestamp(0)
            }
          ],
          causal_links: [%{from_ref: true_source, to_ref: anchor, relation: "generated"}],
          source_hypotheses: [
            %{
              observation_id: anchor,
              source_actor_id: true_source,
              mechanism: "published",
              claimed_source_status: "may_be_spoofed"
            }
          ],
          assumptions: ["The anchor event originated with #{true_source}."],
          predictions: ["Authenticating #{anchor} identifies #{true_source}."],
          falsifiers: ["Authenticated provenance to a different source."],
          metadata: %{simulator_native: true}
        },
        %{round: 0, mode: :simulator_truth}
      )

    attractive_mechanism = attractive_false_mechanism(case_class)

    decoy =
      World.from_candidate(
        %{
          client_id: "world_decoy_#{seed}",
          summary:
            "Attractive alternative centered on #{decoy_source} and #{attractive_mechanism}.",
          mechanism_family: attractive_mechanism,
          actor_roles: [%{actor_id: decoy_source, role: "apparent_source"}],
          actor_knowledge: [
            %{
              actor_id: decoy_source,
              fact_id: "fact_origin",
              status: "may_know",
              by_time: timestamp(0)
            }
          ],
          causal_links: [%{from_ref: decoy_source, to_ref: anchor, relation: "generated"}],
          source_hypotheses: [
            %{
              observation_id: anchor,
              source_actor_id: decoy_source,
              mechanism: "published",
              claimed_source_status: "apparently_direct"
            }
          ],
          assumptions: ["Surface attribution is genuine."],
          predictions: ["Authenticating #{anchor} identifies #{decoy_source}."],
          falsifiers: ["Authenticated provenance to a different source."],
          metadata: %{simulator_native: true}
        },
        %{round: 0, mode: :simulator_decoy}
      )

    alt =
      if case_class == :non_identifiable do
        World.from_candidate(
          %{
            client_id: "world_alt_#{seed}",
            summary: "Same observable source path but hostile rather than protective motive.",
            mechanism_family: "strategic_intimidation",
            actor_roles: [%{actor_id: true_source, role: "hostile_sender"}],
            actor_knowledge: [
              %{
                actor_id: true_source,
                fact_id: "fact_origin",
                status: "knows",
                by_time: timestamp(0)
              }
            ],
            causal_links: [%{from_ref: true_source, to_ref: anchor, relation: "generated"}],
            source_hypotheses: [
              %{
                observation_id: anchor,
                source_actor_id: true_source,
                mechanism: "published",
                claimed_source_status: "may_be_spoofed"
              }
            ],
            assumptions: ["The same sender intended intimidation rather than reassurance."],
            predictions: [
              "All public and limited evidence actions match the protective-motive world."
            ],
            falsifiers: ["Authenticated motive-bearing record."],
            metadata: %{simulator_native: true}
          },
          %{round: 0, mode: :simulator_equivalent}
        )
      end

    same_source_alt =
      if case_class in [:resolvable, :transition] do
        World.from_candidate(
          %{
            client_id: "world_same_source_alt_#{seed}",
            summary: "Same authenticated source but a different causal mechanism.",
            mechanism_family: "ordinary_upstream_coordination",
            actor_roles: [%{actor_id: true_source, role: "informed_sender"}],
            actor_knowledge: [
              %{
                actor_id: true_source,
                fact_id: "fact_origin",
                status: "knows",
                by_time: timestamp(0)
              }
            ],
            causal_links: [%{from_ref: true_source, to_ref: anchor, relation: "generated"}],
            source_hypotheses: [
              %{
                observation_id: anchor,
                source_actor_id: true_source,
                mechanism: "published",
                claimed_source_status: "authenticated_or_compatible"
              }
            ],
            assumptions: [
              "The source is correct but the delivery mechanism is ordinary upstream coordination."
            ],
            predictions: [
              "Authenticating #{anchor} identifies #{true_source} but does not by itself distinguish mechanism."
            ],
            falsifiers: [
              "An authenticated mechanism record identifying a different delivery path."
            ],
            metadata: %{simulator_native: true}
          },
          %{round: 0, mode: :simulator_mechanism_alt}
        )
      end

    decoys =
      cond do
        alt -> [decoy, alt]
        same_source_alt -> [decoy, same_source_alt, sprawling(same_source_alt, observations)]
        true -> [decoy, sprawling(decoy, observations)]
      end

    {true_world, decoys}
  end

  defp sprawling(world, observations) do
    extra =
      Enum.take(observations, 3) |> Enum.map(&"Unobserved auxiliary actor explains #{&1.id}.")

    %{world | id: world.id <> "_sprawl", assumptions: world.assumptions ++ extra}
  end

  defp build_actions(case_class, access_regime, anchor, true_source, seed) do
    auth =
      EvidenceAction.new(%{
        id: "act_auth_anchor",
        kind: :authenticate_source,
        cost_units: 1,
        availability: :public,
        target_ref: anchor,
        description: "Authenticate the source of the anchor observation."
      })

    provenance =
      EvidenceAction.new(%{
        id: "act_provenance",
        kind: :reveal_provenance,
        cost_units: 1,
        availability: :public,
        target_ref: "root_005",
        description: "Reveal whether two visible reports share an upstream source."
      })

    knowledge =
      EvidenceAction.new(%{
        id: "act_knowledge",
        kind: :reveal_actor_knowledge,
        cost_units: 2,
        availability: :limited,
        target_ref: {true_source, "fact_origin"},
        description: "Reveal a timestamped fact-access record for the proposed source actor."
      })

    channel =
      EvidenceAction.new(%{
        id: "act_channel_log",
        kind: :reveal_channel_log,
        cost_units: 3,
        availability: :operator,
        target_ref: "shared_channel",
        description: "Reveal the internal channel-delivery mechanism for the anchor event."
      })

    actions =
      case {case_class, access_regime} do
        {:non_identifiable, :public} -> [auth, provenance]
        {:non_identifiable, :limited} -> [auth, provenance, knowledge]
        {:non_identifiable, :operator} -> [auth, provenance, knowledge]
        {:non_identifiable, :oracle} -> [auth, provenance, knowledge, channel]
        {_, :public} -> [auth, provenance, channel]
        {_, :limited} -> [auth, provenance, knowledge, channel]
        {_, _} -> [auth, provenance, knowledge, channel]
      end

    results = %{
      "act_auth_anchor" => [
        Observation.new(%{
          id: "obs_auth_#{seed}",
          round: 1,
          timestamp: timestamp(200),
          surface:
            "An authenticated audit record identifies #{true_source} as the origin of #{anchor}.",
          observation_type: :audit_record,
          authenticated_source: true_source,
          provenance_ref: "audit_auth",
          access_level: :public,
          metadata: %{authenticates_observation_id: anchor, public_authenticated: true}
        })
      ],
      "act_provenance" => [
        Observation.new(%{
          id: "obs_prov_#{seed}",
          round: 1,
          timestamp: timestamp(201),
          surface:
            "A provenance audit shows two apparently separate reports share one upstream record.",
          observation_type: :provenance_audit,
          provenance_ref: "audit_provenance",
          access_level: :public
        })
      ],
      "act_knowledge" => [
        Observation.new(%{
          id: "obs_know_#{seed}",
          round: 1,
          timestamp: timestamp(202),
          surface:
            "A timestamped access record shows #{true_source} possessed fact_origin before the anchor event.",
          observation_type: :access_log,
          provenance_ref: "audit_knowledge",
          access_level: :limited
        })
      ],
      "act_channel_log" => [
        Observation.new(%{
          id: "obs_channel_#{seed}",
          round: 1,
          timestamp: timestamp(203),
          surface:
            "The channel log identifies the hidden delivery mechanism as #{true_mechanism(case_class)}.",
          observation_type: :channel_log,
          provenance_ref: "audit_channel",
          access_level: :operator,
          metadata: %{authenticates_mechanism: true_mechanism(case_class)}
        })
      ]
    }

    {actions, results}
  end

  defp build_targets(case_class, anchor, true_source, mechanism) do
    base = [
      %{
        id: "target_source",
        proposition: "Was #{true_source} the actual source of #{anchor}?",
        query: %{kind: :source_actor, observation_id: anchor, actor_id: true_source},
        resolution: :source
      },
      %{
        id: "target_mechanism",
        proposition: "Was the generating mechanism #{mechanism}?",
        query: %{kind: :mechanism_family, value: mechanism},
        resolution: :mechanism
      }
    ]

    if case_class == :non_identifiable do
      base ++
        [
          %{
            id: "target_motive",
            proposition: "Did the sender act from a protective rather than hostile motive?",
            query: %{kind: :actor_role, actor_id: true_source, role: "protective_sender"},
            resolution: :motive
          }
        ]
    else
      base
    end
  end

  defp expected_status(%Env{case_class: :resolvable}, %{resolution: resolution})
       when resolution in [:source, :mechanism], do: :supported

  defp expected_status(env, %{resolution: :source}) do
    if MapSet.member?(env.executed_actions, "act_auth_anchor"), do: :supported, else: :unresolved
  end

  defp expected_status(env, %{resolution: :mechanism}) do
    if MapSet.member?(env.executed_actions, "act_channel_log"), do: :supported, else: :unresolved
  end

  defp expected_status(%Env{case_class: :non_identifiable, access_regime: :oracle}, %{
         resolution: :motive
       }),
       do: :supported

  defp expected_status(_env, %{resolution: :motive}), do: :unresolved

  defp mask_observation(obs, :oracle), do: obs
  defp mask_observation(obs, :operator), do: obs

  defp mask_observation(obs, regime) do
    if obs.access_level in [:public, regime] do
      authenticated_source =
        if obs.metadata[:public_authenticated], do: obs.authenticated_source, else: nil

      %{
        obs
        | authenticated_source: authenticated_source,
          metadata: Map.drop(obs.metadata, [:hidden_truth])
      }
    else
      %{
        obs
        | surface: "[withheld at #{obs.access_level} access]",
          authenticated_source: nil,
          metadata: %{withheld: true}
      }
    end
  end

  defp access_allows?(_regime, :public), do: true
  defp access_allows?(regime, :limited), do: regime in [:limited, :operator, :oracle]
  defp access_allows?(regime, :operator), do: regime in [:operator, :oracle]
  defp access_allows?(:oracle, :oracle), do: true
  defp access_allows?(_, _), do: false

  defp world_from_request(request) do
    raw = Util.get(request.state, :world, %{})

    World.from_candidate(%{
      client_id: Util.get(raw, :id, request.world_id),
      summary: Util.get(raw, :summary, ""),
      mechanism_family: Util.get(raw, :mechanism_family, "unknown"),
      actor_roles: Util.get(raw, :actor_roles, []),
      actor_knowledge: Util.get(raw, :actor_knowledge, []),
      causal_links: Util.get(raw, :causal_links, []),
      source_hypotheses: Util.get(raw, :source_hypotheses, []),
      assumptions: Util.get(raw, :assumptions, []),
      predictions: Util.get(raw, :predictions, []),
      falsifiers: Util.get(raw, :falsifiers, [])
    })
  end

  defp oracle_weight(env, world, obs_id) do
    facts = Map.get(env.hidden_observation_facts, obs_id, %{evidence_bias: :neutral})

    true? =
      world.mechanism_family == env.true_world.mechanism_family or
        (env.case_class == :non_identifiable and
           world.mechanism_family in ["strategic_reassurance", "strategic_intimidation"])

    decoy? = world.mechanism_family == attractive_false_mechanism(env.case_class)

    source_match? =
      World.source_actor(world, env.anchor_observation_id) == env.true_source_actor_id

    case facts.evidence_bias do
      true -> if(true?, do: 2, else: if(source_match?, do: 1, else: -1))
      :decoy -> if(decoy?, do: 2, else: if(true?, do: -1, else: 0))
      :source -> if(source_match?, do: 2, else: -2)
      _ -> 0
    end
  end

  defp value_for_weight(-2), do: :strongly_against
  defp value_for_weight(-1), do: :against
  defp value_for_weight(0), do: :neutral
  defp value_for_weight(1), do: :supports
  defp value_for_weight(2), do: :strongly_supports
  defp clamp(value, low, _high) when value < low, do: low
  defp clamp(value, _low, high) when value > high, do: high
  defp clamp(value, _low, _high), do: value

  defp bias_for(1, _case_class), do: :source
  defp bias_for(2, :resolvable), do: true
  defp bias_for(i, :transition) when i <= 8 and rem(i, 2) == 0, do: :decoy
  defp bias_for(i, _case_class) when rem(i, 5) == 0, do: true
  defp bias_for(_i, _case_class), do: :neutral

  defp surface_for(1, _copied, true_source, decoy, _bias, seed, :resolvable),
    do:
      "A highly salient channel message appeared with surface attribution to #{decoy}; marker #{seed}-anchor made it unusually specific. A public audit signature authenticates origin #{true_source}."

  defp surface_for(1, _copied, _true_source, decoy, _bias, seed, _case_class),
    do:
      "A highly salient channel message appeared with surface attribution to #{decoy}; marker #{seed}-anchor made it unusually specific."

  defp surface_for(2, _copied, true_source, _decoy, true, _seed, :resolvable),
    do:
      "A public deployment audit independently records external leak followed by ordinary amplification and ties the upstream event to #{true_source}."

  defp surface_for(i, copied, _true, _decoy, _bias, _seed, _case_class) when not is_nil(copied),
    do: "Actor relay #{i} explicitly quotes the report first seen in obs_#{pad(copied)}."

  defp surface_for(i, _copied, _true, decoy, :decoy, _seed, _case_class),
    do:
      "Observation #{i} looks consistent with direct intervention by #{decoy}, but the source is not authenticated."

  defp surface_for(i, _copied, true_source, _decoy, true, _seed, _case_class),
    do:
      "Observation #{i} contains a timing/provenance detail more naturally explained if #{true_source} had upstream knowledge."

  defp surface_for(i, _copied, _true, _decoy, _bias, seed, _case_class),
    do:
      "Ordinary channel event #{i} in case #{seed}; informative only in combination with provenance and actor state."

  defp true_mechanism(:non_identifiable), do: "strategic_reassurance"
  defp true_mechanism(_), do: "external_leak_then_amplification"
  defp attractive_false_mechanism(:non_identifiable), do: "direct_operator_intervention"
  defp attractive_false_mechanism(_), do: "direct_operator_intervention"

  defp actor_id(i), do: "actor_#{pad(i)}"
  defp obs_id(i), do: "obs_#{pad(i)}"
  defp pad(i), do: i |> Integer.to_string() |> String.pad_leading(3, "0")

  defp timestamp(i),
    do: DateTime.add(~U[2026-01-01 00:00:00Z], i * 60, :second) |> DateTime.to_iso8601()
end
