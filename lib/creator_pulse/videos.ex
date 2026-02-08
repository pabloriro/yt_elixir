defmodule CreatorPulse.Videos do
  @moduledoc """
  The Videos context.
  """

  import Ecto.Query, warn: false
  alias CreatorPulse.Repo

  alias CreatorPulse.Videos.Video
  alias CreatorPulse.Analytics.Channel
  alias CreatorPulse.YoutubeAPI

  @doc """
  Returns the list of videos for a specific channel.

  ## Examples

      iex> list_videos(123)
      [%Video{}, ...]

  """
  def list_videos(channel_id) do
    from(v in Video, where: v.channel_id == ^channel_id, order_by: [desc: v.published_at])
    |> Repo.all()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Gets a single video by youtube_id.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video_by_youtube_id!("abc123")
      %Video{}

  """
  def get_video_by_youtube_id!(youtube_id) do
    Repo.get_by!(Video, youtube_id: youtube_id)
  end

  @doc """
  Creates or updates a video.

  If a video with the same youtube_id exists, it updates it.
  Otherwise, it creates a new video.

  ## Examples

      iex> create_or_update_video(%{field: value})
      {:ok, %Video{}}

  """
  def create_or_update_video(attrs) do
    case Repo.get_by(Video, youtube_id: attrs[:youtube_id] || attrs["youtube_id"]) do
      nil ->
        %Video{}
        |> Video.changeset(attrs)
        |> Repo.insert()

      video ->
        video
        |> Video.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Imports videos from a channel using the YouTube API.

  ## Examples

      iex> import_videos_from_channel(channel)
      {:ok, [%Video{}, ...]}

  """
  def import_videos_from_channel(%Channel{} = channel) do
    case YoutubeAPI.get_channel_videos(channel.youtube_id) do
      {:ok, videos_data} ->
        results =
          Enum.map(videos_data, fn video_data ->
            create_or_update_video(%{
              youtube_id: video_data.id,
              title: video_data.title,
              description: video_data.description,
              thumbnail: video_data.thumbnail,
              channel_id: channel.id,
              published_at: video_data.published_at,
              view_count: video_data.view_count,
              like_count: video_data.like_count,
              comment_count: video_data.comment_count
            })
          end)

        successful_imports =
          Enum.filter(results, fn
            {:ok, _video} -> true
            _ -> false
          end)

        {:ok, Enum.map(successful_imports, fn {:ok, video} -> video end)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end
end
