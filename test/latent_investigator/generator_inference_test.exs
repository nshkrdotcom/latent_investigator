defmodule LatentInvestigator.GeneratorInferenceTest do
  use ExUnit.Case, async: true
  alias LatentInvestigator.{Generator, Investigation}

  test "parses strict structured candidate worlds from Inference" do
    object = %{
      "worlds" => [
        %{
          "client_id" => "candidate-1",
          "summary" => "External actor seeded a message.",
          "mechanism_family" => "external_leak",
          "actor_roles" => [],
          "actor_knowledge" => [],
          "causal_links" => [],
          "source_hypotheses" => [],
          "assumptions" => [],
          "predictions" => [],
          "falsifiers" => []
        }
      ]
    }

    client =
      Inference.Client.new!(
        adapter: Inference.Adapters.Mock,
        provider: :mock,
        model: "mock",
        adapter_opts: [response_object: object]
      )

    assert {:ok, [world]} =
             LatentInvestigator.Generator.Inference.initial(
               %Generator.Context{client: client, provider: :mock},
               Investigation.new(),
               []
             )

    assert world.id == "candidate-1"
    assert world.mechanism_family == "external_leak"
  end
end
