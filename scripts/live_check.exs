# This file sends model requests. Run only after explicitly approving live execution.
mode =
  case System.argv() do
    [mode] when mode in ["baseline", "structured", "system-one"] -> mode
    _ -> raise "Usage: mix run scripts/live_check.exs baseline|structured|system-one"
  end

Code.require_file("live_setup.exs", __DIR__)
client = LatentInvestigator.Config.inference_client!(:frontier)

result =
  case mode do
    "baseline" ->
      LatentInvestigator.Experiment.Gate0.run(
        client: client,
        profiles: [:smoke],
        seeds: [1],
        case_class: :transition,
        access_regime: :public,
        round_budget: 1
      )

    "structured" ->
      LatentInvestigator.Runner.run(
        seed: 1,
        profile: :smoke,
        case_class: :transition,
        access_regime: :public,
        generator: LatentInvestigator.Generator.Inference,
        generator_context: %LatentInvestigator.Generator.Context{
          client: client,
          provider: :frontier,
          model: client.model
        },
        evaluator: LatentInvestigator.Evaluator.Inference,
        evaluator_context: %LatentInvestigator.Evaluator.Context{
          client: client,
          provider: :frontier,
          model: client.model,
          config: %{batch_size: 8}
        },
        k_initial: 4,
        round_budget: 1,
        max_alive_worlds: 8,
        persist: true,
        arm: :b1
      )

    "system-one" ->
      SystemOneSDK.evaluate(
        LatentInvestigator.Config.system_one_client!(),
        "The box is blue.",
        blue: SystemOneSDK.noul("Does the text explicitly say the box is blue?")
      )
  end

case result do
  {:ok, value} ->
    File.mkdir_p!("tmp/live_checks")
    path = "tmp/live_checks/#{mode}-#{System.system_time(:millisecond)}.txt"
    File.write!(path, inspect(value, pretty: true, limit: :infinity))
    IO.puts("Result saved to #{path}")

  {:error, reason} ->
    raise "Live check failed: #{inspect(reason)}"
end
