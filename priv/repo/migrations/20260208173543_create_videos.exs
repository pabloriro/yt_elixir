defmodule CreatorPulse.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :youtube_id, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :thumbnail, :string
      add :channel_id, references(:channels, on_delete: :nothing)
      add :published_at, :utc_datetime
      add :view_count, :integer
      add :like_count, :integer
      add :comment_count, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:videos, [:channel_id])
    create unique_index(:videos, [:youtube_id])
  end
end
