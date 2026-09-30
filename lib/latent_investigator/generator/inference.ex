defmodule LatentInvestigator.Generator.Inference do
  @moduledoc "Structured candidate generation and attack through Inference."
  @behaviour LatentInvestigator.Generator

  alias LatentInvestigator.{Generator.Context, Prompt, Schema, Util, World}

  @impl true
  def initial(%Context{} = context, inv, opts \\ []), do: generate(context, inv, :initial, opts)

  @impl true
  def repair(%Context{} = context, inv, rejected, opts \\ []) do
    generate(
      context,
      inv,
      :repair,
      Keyword.put(opts, :rejected_worlds, Enum.map(rejected, & &1.id))
    )
  end

  @impl true
  def attack(%Context{client: %Inference.Client{} = client} = context, inv, worlds, _opts \\ []) do
    with {:ok, response} <-
           Inference.complete(
             client,
             Prompt.attack(inv, worlds),
             response_opts(context, "latent_investigator_attack", Schema.attack())
           ),
         object when is_map(object) <- response.object,
         alternatives when is_list(alternatives) <- Util.get(object, :alternative_worlds, []) do
      parent_ids = Enum.map(worlds, & &1.id)

      {:ok,
       Enum.map(
         alternatives,
         &World.from_candidate(
           &1,
           generation_meta(context, inv.round, :attack, parent_ids, response)
         )
       )}
    else
      nil -> {:error, :structured_object_missing}
      {:error, _} = error -> error
      other -> {:error, {:invalid_attack_response, other}}
    end
  end

  defp generate(%Context{client: %Inference.Client{} = client} = context, inv, mode, opts) do
    prompt = Prompt.generate(inv, mode, opts)

    with {:ok, response} <-
           Inference.complete(
             client,
             prompt,
             response_opts(context, "latent_investigator_worlds", Schema.candidate_worlds())
           ),
         object when is_map(object) <- response.object,
         worlds when is_list(worlds) <- Util.get(object, :worlds, []) do
      {:ok,
       Enum.map(
         worlds,
         &World.from_candidate(&1, generation_meta(context, inv.round, mode, [], response))
       )}
    else
      nil -> {:error, :structured_object_missing}
      {:error, _} = error -> error
      other -> {:error, {:invalid_generation_response, other}}
    end
  end

  defp response_opts(context, name, schema) do
    opts = [response_format: {:json_schema, %{name: name, schema: schema, strict: true}}]
    if is_binary(context.model), do: Keyword.put(opts, :model, context.model), else: opts
  end

  defp generation_meta(context, round, mode, parent_ids, response) do
    %{
      round: round,
      mode: mode,
      provider: response.provider || context.provider,
      lane: context.provider,
      model: response.model || context.model,
      parent_ids: parent_ids,
      usage: response.usage,
      cost: response.cost,
      response_id: response.id
    }
  end
end
