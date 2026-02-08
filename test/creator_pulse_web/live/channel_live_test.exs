defmodule CreatorPulseWeb.ChannelLiveTest do
  use CreatorPulseWeb.ConnCase

  import Phoenix.LiveViewTest
  import CreatorPulse.AnalyticsFixtures

  @create_attrs %{description: "some description", title: "some title", youtube_id: "some youtube_id", thumbnail: "some thumbnail"}
  @update_attrs %{description: "some updated description", title: "some updated title", youtube_id: "some updated youtube_id", thumbnail: "some updated thumbnail"}
  @invalid_attrs %{description: nil, title: nil, youtube_id: nil, thumbnail: nil}
  defp create_channel(_) do
    channel = channel_fixture()

    %{channel: channel}
  end

  describe "Index" do
    setup [:create_channel]

    test "lists all channels", %{conn: conn, channel: channel} do
      {:ok, _index_live, html} = live(conn, ~p"/channels")

      assert html =~ "Listing Channels"
      assert html =~ channel.youtube_id
    end

    test "saves new channel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/channels")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Channel")
               |> render_click()
               |> follow_redirect(conn, ~p"/channels/new")

      assert render(form_live) =~ "New Channel"

      assert form_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#channel-form", channel: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/channels")

      html = render(index_live)
      assert html =~ "Channel created successfully"
      assert html =~ "some youtube_id"
    end

    test "updates channel in listing", %{conn: conn, channel: channel} do
      {:ok, index_live, _html} = live(conn, ~p"/channels")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#channels-#{channel.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/channels/#{channel}/edit")

      assert render(form_live) =~ "Edit Channel"

      assert form_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#channel-form", channel: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/channels")

      html = render(index_live)
      assert html =~ "Channel updated successfully"
      assert html =~ "some updated youtube_id"
    end

    test "deletes channel in listing", %{conn: conn, channel: channel} do
      {:ok, index_live, _html} = live(conn, ~p"/channels")

      assert index_live |> element("#channels-#{channel.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#channels-#{channel.id}")
    end
  end

  describe "Show" do
    setup [:create_channel]

    test "displays channel", %{conn: conn, channel: channel} do
      {:ok, _show_live, html} = live(conn, ~p"/channels/#{channel}")

      assert html =~ "Show Channel"
      assert html =~ channel.youtube_id
    end

    test "updates channel and returns to show", %{conn: conn, channel: channel} do
      {:ok, show_live, _html} = live(conn, ~p"/channels/#{channel}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/channels/#{channel}/edit?return_to=show")

      assert render(form_live) =~ "Edit Channel"

      assert form_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#channel-form", channel: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/channels/#{channel}")

      html = render(show_live)
      assert html =~ "Channel updated successfully"
      assert html =~ "some updated youtube_id"
    end
  end
end
