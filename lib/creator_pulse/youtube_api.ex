defmodule CreatorPulse.YoutubeAPI do
  def get_channel_info(channel_id) do
    api_key = System.get_env("YT_API_KEY")
    url = "https://www.googleapis.com/youtube/v3/channels"

    case Req.get(url, params: [part: "snippet", id: channel_id, key: api_key]) do
      {:ok, %{status: 200, body: %{"items" => [item | _]}}} ->
        snippet = item["snippet"]
        {:ok, %{
          title: snippet["title"],
          description: snippet["description"],
          thumbnail: snippet["thumbnails"]["default"]["url"]
        }}

      {:ok, response} ->
        # ESTO ES LO IMPORTANTE: Imprimirá el error real en tu consola
        IO.puts("--- ERROR DE YOUTUBE ---")
        IO.inspect(response.body)
        {:error, "Canal no encontrado"}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, "Error de conexión"}
    end
  end
end