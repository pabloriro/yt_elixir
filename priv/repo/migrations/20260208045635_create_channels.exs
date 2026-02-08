defmodule CreatorPulse.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :youtube_id, :string
      add :title, :string
      add :thumbnail, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
