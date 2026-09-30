# Explicitly loaded by the live scripts; constructing clients makes no model calls.
query_opts = [
  allow_unknown_model: true,
  skip_git_repo_check: true,
  reasoning_effort: :medium,
  transport_timeout_ms: 300_000,
  stream_timeout_ms: 300_000,
  cwd: System.tmp_dir!()
]

frontier =
  Inference.Client.agent_session!(
    adapter: Inference.Adapters.ASM,
    provider: :codex,
    model: "gpt-6.1-sol",
    adapter_opts: [query_opts: query_opts]
  )

:ok = Inference.Client.validate_adapter_kind(frontier)

{:ok, _} =
  ASM.Options.validate(
    [provider: :codex, model: frontier.model, completion_only: true] ++
      Keyword.drop(query_opts, [:stream_timeout_ms]),
    ASM.Options.Codex.schema()
  )

for name <- [:completion_only, :response_format_json_schema] do
  unless Enum.any?(
           Inference.capabilities(frontier),
           &(&1.name == name and &1.support == :supported)
         ) do
    raise "Codex bridge does not advertise #{name}"
  end
end

api_key = System.fetch_env!("TYPESAFE_API_KEY")
if String.trim(api_key) == "", do: raise("TYPESAFE_API_KEY is blank")

system_one =
  SystemOneSDK.new_client(
    api_key: api_key,
    base_url: System.get_env("TYPESAFE_BASE_URL", "https://api.typesafe.ai"),
    model: "jev-latest",
    timeout_ms: 60_000
  )

Application.put_env(:latent_investigator, :frontier_inference_client, frontier)
Application.put_env(:latent_investigator, :system_one_client, system_one)
