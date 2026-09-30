defmodule LatentInvestigator.Config do
  @moduledoc "Runtime model-client configuration. Live provider SDKs are host-owned optional dependencies."

  def inference_client!(lane) when lane in [:frontier, :cheap] do
    case Application.get_env(:latent_investigator, client_key(lane)) do
      %Inference.Client{} = client -> client
      nil -> raise "No #{lane} Inference.Client configured. Inject one with Application.put_env(:latent_investigator, #{client_key(lane)}, client)."
      other -> raise "Invalid #{lane} inference client: #{inspect(other)}"
    end
  end

  defp client_key(:frontier), do: :frontier_inference_client
  defp client_key(:cheap), do: :cheap_inference_client

  def system_one_client! do
    case Application.get_env(:latent_investigator, :system_one_client) do
      %SystemOneSDK.Client{} = client -> client
      nil -> SystemOneSDK.new_client()
      other -> raise "Invalid SystemOneSDK client: #{inspect(other)}"
    end
  end
end
