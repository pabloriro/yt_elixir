defmodule CreatorPulse.AnalyticsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CreatorPulse.Analytics` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        description: "some description",
        thumbnail: "some thumbnail",
        title: "some title",
        youtube_id: "some youtube_id"
      })
      |> CreatorPulse.Analytics.create_channel()

    channel
  end
end
