defmodule CreatorPulseWeb.VideoLive.Index do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Videos
  alias CreatorPulse.Analytics

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Videos for <%= @channel.title %>
        <:subtitle>Manage and view videos from this channel</:subtitle>
        <:actions>
          <.button navigate={~p"/channels/#{@channel}"}>
            <.icon name="hero-arrow-left" /> Back to Channel
          </.button>
          <.button variant="primary" phx-click="import_videos">
            <.icon name="hero-arrow-down-tray" /> Import from YouTube
          </.button>
        </:actions>
      </.header>

      <.table
        id="videos"
        rows={@streams.videos}
        row_click={fn {_id, video} -> JS.navigate(~p"/channels/#{@channel}/videos/#{video}") end}
      >
        <:col :let={{_id, video}} label="Thumbnail">
          <img src={video.thumbnail} alt={video.title} class="w-32 h-18 object-cover rounded" />
        </:col>
        <:col :let={{_id, video}} label="Title">{video.title}</:col>
        <:col :let={{_id, video}} label="Published">
          <%= if video.published_at do %>
            <%= Calendar.strftime(video.published_at, "%Y-%m-%d") %>
          <% else %>
            N/A
          <% end %>
        </:col>
        <:col :let={{_id, video}} label="Views">
          <%= CreatorPulseWeb.format_number(video.view_count) %>
        </:col>
        <:col :let={{_id, video}} label="Likes">
          <%= CreatorPulseWeb.format_number(video.like_count) %>
        </:col>
        <:action :let={{_id, video}}>
          <div class="sr-only">
            <.link navigate={~p"/channels/#{@channel}/videos/#{video}"}>Show</.link>
          </div>
          <.link navigate={~p"/channels/#{@channel}/videos/#{video}"}>View Details</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"channel_id" => channel_id}, _session, socket) do
    channel = Analytics.get_channel!(channel_id)

    {:ok,
     socket
     |> assign(:page_title, "Videos for #{channel.title}")
     |> assign(:channel, channel)
     |> stream(:videos, list_videos(channel.id))}
  end

  @impl true
  def handle_event("import_videos", _, socket) do
    case Videos.import_videos_from_channel(socket.assigns.channel) do
      {:ok, imported_videos} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully imported #{length(imported_videos)} videos")
         |> stream(:videos, list_videos(socket.assigns.channel.id), reset: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to import videos: #{reason}")
         |> stream(:videos, list_videos(socket.assigns.channel.id), reset: true)}
    end
  end

  defp list_videos(channel_id) do
    Videos.list_videos(channel_id)
  end
end
