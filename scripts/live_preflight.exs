Code.require_file("live_setup.exs", __DIR__)

cli = System.find_executable("codex") || raise "codex executable is unavailable"
{_, 0} = System.cmd(cli, ["login", "status"], stderr_to_stdout: true)

IO.puts(
  "PASS: local client construction, ASM option validation, completion-only/schema capabilities, Codex login, TypeSafe credential presence"
)

IO.puts("Frontier: codex / gpt-6.1-sol; System One: jev-latest")
IO.puts("Live availability and model acceptance: NOT_RUN. No model requests sent.")
