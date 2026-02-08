defmodule CreatorPulse.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :thumbnail, :string
    field :title, :string
    field :youtube_id, :string
    field :published_at, :utc_datetime
    field :view_count, :integer
    field :like_count, :integer
    field :comment_count, :integer

    belongs_to :channel, CreatorPulse.Analytics.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:youtube_id, :title, :description, :thumbnail, :channel_id, :published_at, :view_count, :like_count, :comment_count])
    |> validate_required([:youtube_id, :title])
    |> unique_constraint(:youtube_id)
    |> assoc_constraint(:channel)
  end
end
