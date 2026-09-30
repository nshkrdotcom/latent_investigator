defmodule LatentInvestigator.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/latent_investigator"

  def project do
    [
      app: :latent_investigator,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [ci: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {LatentInvestigator.Application, []}
    ]
  end

  defp description do
    "Deterministic epistemic investigation core and causal hypothesis exploration engine for strategic network environments."
  end

  defp package do
    [
      name: :latent_investigator,
      description: description(),
      maintainers: ["nshkrdotcom"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib config guides assets .formatter.exs mix.exs README.md LICENSE CHANGELOG.md VERSION)
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "Latent Investigator",
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @source_url,
      logo: "assets/latent_investigator.svg",
      assets: "assets",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules()
    ]
  end

  defp extras do
    [
      "README.md",
      "CHANGELOG.md",
      "LICENSE",
      "guides/getting_started.md",
      "guides/architecture.md",
      "guides/simulator.md",
      "guides/provenance_and_constraints.md",
      "guides/aggregation_and_search.md",
      "guides/evaluators_and_generators.md",
      "guides/experiments_and_qualification.md"
    ]
  end

  defp groups_for_extras do
    [
      Overview: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ],
      Guides: [
        "guides/getting_started.md",
        "guides/architecture.md",
        "guides/simulator.md",
        "guides/provenance_and_constraints.md",
        "guides/aggregation_and_search.md",
        "guides/evaluators_and_generators.md",
        "guides/experiments_and_qualification.md"
      ]
    ]
  end

  defp groups_for_modules do
    [
      "Investigation Core": [
        LatentInvestigator,
        LatentInvestigator.Investigation,
        LatentInvestigator.World,
        LatentInvestigator.Actor,
        LatentInvestigator.Observation,
        LatentInvestigator.EvidenceAction,
        LatentInvestigator.Judgment,
        LatentInvestigator.Target,
        LatentInvestigator.ID
      ],
      "Epistemic Reasoning": [
        LatentInvestigator.Provenance,
        LatentInvestigator.Constraint,
        LatentInvestigator.Aggregator,
        LatentInvestigator.Search,
        LatentInvestigator.Acquisition
      ],
      Simulator: [
        LatentInvestigator.Simulator,
        LatentInvestigator.Simulator.StrategicNetwork
      ],
      Generators: [
        LatentInvestigator.Generator,
        LatentInvestigator.Generator.Inference,
        LatentInvestigator.Generator.Oracle
      ],
      Evaluators: [
        LatentInvestigator.Evaluator,
        LatentInvestigator.Evaluator.Inference,
        LatentInvestigator.Evaluator.SystemOne,
        LatentInvestigator.Evaluator.Oracle,
        LatentInvestigator.Evaluator.Context,
        LatentInvestigator.Evaluator.JudgmentRequest,
        LatentInvestigator.LocalJudgments
      ],
      "Baselines & Experiments": [
        LatentInvestigator.Baseline.Monolithic,
        LatentInvestigator.Experiment.Smoke,
        LatentInvestigator.Experiment.Gate0,
        LatentInvestigator.Experiment.Gate1,
        LatentInvestigator.Experiment.Gate2,
        LatentInvestigator.Experiment.GenerationBottleneck,
        LatentInvestigator.Experiment.AccessCurve,
        LatentInvestigator.Experiment.CostProjection,
        LatentInvestigator.Experiment.Common,
        LatentInvestigator.Experiment.Metrics
      ],
      "Artifacts & Replay": [
        LatentInvestigator.ArtifactStore,
        LatentInvestigator.Replay,
        LatentInvestigator.Report,
        LatentInvestigator.JSON,
        LatentInvestigator.Prompt,
        LatentInvestigator.Schema,
        LatentInvestigator.Config,
        LatentInvestigator.Runner,
        LatentInvestigator.Util
      ]
    ]
  end

  defp deps do
    [
      {:system_one_sdk, path: "../system_one_sdk"},
      {:inference, path: "../inference"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test --warnings-as-errors"
      ]
    ]
  end
end
