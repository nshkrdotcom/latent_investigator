import Config

config :latent_investigator,
  artifact_root: "tmp/runs",
  default_profile: :smoke,
  default_case_class: :transition,
  default_access_regime: :public,
  round_budget: 3,
  max_alive_worlds: 32,
  fit_gap_limit: 0.75,
  protected_diversity_slots: 4,
  attack_worlds_per_round: 2,
  local_judgment_batch_size: 1
