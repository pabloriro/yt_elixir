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

  @doc """
  Gets videos from a channel using the YouTube API.

  First fetches the channel's uploads playlist ID, then fetches videos from that playlist.
  """
  def get_channel_videos(channel_id) do
    api_key = System.get_env("YT_API_KEY")

    # First, get the channel's uploads playlist ID
    channel_url = "https://www.googleapis.com/youtube/v3/channels"

    case Req.get(channel_url, params: [part: "contentDetails", id: channel_id, key: api_key]) do
      {:ok, %{status: 200, body: %{"items" => [item | _]}}} ->
        uploads_playlist_id = get_in(item, ["contentDetails", "relatedPlaylists", "uploads"])

        if uploads_playlist_id do
          fetch_playlist_videos(uploads_playlist_id, api_key)
        else
          {:error, "No uploads playlist found"}
        end

      {:ok, response} ->
        IO.puts("--- ERROR DE YOUTUBE (GET CHANNEL) ---")
        IO.inspect(response.body)
        {:error, "Canal no encontrado"}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, "Error de conexión"}
    end
  end

  # Fetch videos from a playlist and get their statistics
  defp fetch_playlist_videos(playlist_id, api_key, max_results \\ 25) do
    playlist_url = "https://www.googleapis.com/youtube/v3/playlistItems"

    case Req.get(playlist_url, params: [part: "snippet,contentDetails", playlistId: playlist_id, maxResults: max_results, key: api_key]) do
      {:ok, %{status: 200, body: %{"items" => items}}} when is_list(items) ->
        # Extract video IDs
        video_ids = Enum.map(items, fn item -> item["contentDetails"]["videoId"] end)

        # Get video statistics
        case get_video_stats(video_ids) do
          {:ok, stats_map} ->
            videos =
              Enum.map(items, fn item ->
                snippet = item["snippet"]
                video_id = item["contentDetails"]["videoId"]
                stats = Map.get(stats_map, video_id, %{})

                # Parse published_at from ISO 8601 format
                published_at =
                  case snippet["publishedAt"] do
                    nil -> nil
                    date_string -> parse_youtube_datetime(date_string)
                  end

                %{
                  id: video_id,
                  title: snippet["title"],
                  description: snippet["description"],
                  thumbnail: get_thumbnail(snippet),
                  published_at: published_at,
                  view_count: Map.get(stats, "viewCount", 0) |> parse_int(),
                  like_count: Map.get(stats, "likeCount", 0) |> parse_int(),
                  comment_count: Map.get(stats, "commentCount", 0) |> parse_int()
                }
              end)

            {:ok, videos}

          {:error, _reason} ->
            # Return videos without stats if stats fetch fails
            videos =
              Enum.map(items, fn item ->
                snippet = item["snippet"]
                video_id = item["contentDetails"]["videoId"]

                published_at =
                  case snippet["publishedAt"] do
                    nil -> nil
                    date_string -> parse_youtube_datetime(date_string)
                  end

                %{
                  id: video_id,
                  title: snippet["title"],
                  description: snippet["description"],
                  thumbnail: get_thumbnail(snippet),
                  published_at: published_at,
                  view_count: 0,
                  like_count: 0,
                  comment_count: 0
                }
              end)

            {:ok, videos}
        end

      {:ok, response} ->
        IO.puts("--- ERROR DE YOUTUBE (PLAYLIST ITEMS) ---")
        IO.inspect(response.body)
        {:error, "Error fetching playlist items"}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, "Error de conexión"}
    end
  end

  @doc """
  Gets statistics for videos by their IDs.
  """
  def get_video_stats(video_ids) when is_list(video_ids) do
    api_key = System.get_env("YT_API_KEY")
    url = "https://www.googleapis.com/youtube/v3/videos"

    id_param = Enum.join(video_ids, ",")

    case Req.get(url, params: [part: "statistics", id: id_param, key: api_key]) do
      {:ok, %{status: 200, body: %{"items" => items}}} when is_list(items) ->
        stats_map =
          Enum.reduce(items, %{}, fn item, acc ->
            video_id = item["id"]
            statistics = item["statistics"] || %{}
            Map.put(acc, video_id, statistics)
          end)

        {:ok, stats_map}

      {:ok, response} ->
        IO.puts("--- ERROR DE YOUTUBE (VIDEO STATS) ---")
        IO.inspect(response.body)
        {:error, "Error fetching video statistics"}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, "Error de conexión"}
    end
  end

  def get_video_stats(video_id) when is_binary(video_id) do
    case get_video_stats([video_id]) do
      {:ok, stats_map} ->
        {:ok, Map.get(stats_map, video_id, %{})}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Parse YouTube's ISO 8601 datetime format to UTC datetime
  defp parse_youtube_datetime(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  # Get the highest resolution thumbnail available
  defp get_thumbnail(snippet) do
    thumbnails = snippet["thumbnails"] || %{}

    # Try to get the highest quality thumbnail available
    thumbnails["maxres"]["url"] ||
      thumbnails["standard"]["url"] ||
      thumbnails["high"]["url"] ||
      thumbnails["medium"]["url"] ||
      thumbnails["default"]["url"]
  end

  # Parse integer from string or return 0
  defp parse_int(value) when is_integer(value), do: value
  defp parse_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> 0
    end
  end
  defp parse_int(_), do: 0
end