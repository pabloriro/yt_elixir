defmodule CreatorPulse.Analytics.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :description, :string
    field :thumbnail, :string
    field :title, :string
    field :youtube_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:youtube_id, :title, :thumbnail, :description]) # <-- ¡Aquí deben estar todos!
    |> validate_required([:youtube_id, :title]) # Solo estos dos son obligatorios para que no de error
  end
end