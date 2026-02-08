defmodule CreatorPulse.AnalyticsTest do
  use CreatorPulse.DataCase

  alias CreatorPulse.Analytics

  describe "channels" do
    alias CreatorPulse.Analytics.Channel

    import CreatorPulse.AnalyticsFixtures

    @invalid_attrs %{description: nil, title: nil, youtube_id: nil, thumbnail: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Analytics.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Analytics.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{description: "some description", title: "some title", youtube_id: "some youtube_id", thumbnail: "some thumbnail"}

      assert {:ok, %Channel{} = channel} = Analytics.create_channel(valid_attrs)
      assert channel.description == "some description"
      assert channel.title == "some title"
      assert channel.youtube_id == "some youtube_id"
      assert channel.thumbnail == "some thumbnail"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Analytics.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", youtube_id: "some updated youtube_id", thumbnail: "some updated thumbnail"}

      assert {:ok, %Channel{} = channel} = Analytics.update_channel(channel, update_attrs)
      assert channel.description == "some updated description"
      assert channel.title == "some updated title"
      assert channel.youtube_id == "some updated youtube_id"
      assert channel.thumbnail == "some updated thumbnail"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Analytics.update_channel(channel, @invalid_attrs)
      assert channel == Analytics.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Analytics.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Analytics.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Analytics.change_channel(channel)
    end
  end
end
