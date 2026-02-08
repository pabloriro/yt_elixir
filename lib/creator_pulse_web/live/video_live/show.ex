defmodule CreatorPulseWeb.VideoLive.Show do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Videos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <%= @video.title %>
        <:subtitle>Video details and statistics</:subtitle>
        <:actions>
          <.button navigate={~p"/channels/#{@channel}/videos"}>
            <.icon name="hero-arrow-left" /> Back to Videos
          </.button>
          <.button variant="primary" href={"https://www.youtube.com/watch?v=#{@video.youtube_id}"} target="_blank">
            <.icon name="hero-play" /> Watch on YouTube
          </.button>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-4">
          <div>
            <img src={@video.thumbnail} alt={@video.title} class="w-full rounded-lg shadow-lg" />
          </div>

          <.list>
            <:item title="YouTube ID">
              <code class="text-sm bg-gray-100 px-2 py-1 rounded"><%= @video.youtube_id %></code>
            </:item>
            <:item title="Published">
              <%= if @video.published_at do %>
                <%= Calendar.strftime(@video.published_at, "%A, %B %e, %Y at %I:%M %p") %>
              <% else %>
                N/A
              <% end %>
            </:item>
          </.list>
        </div>

        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold mb-4">Statistics</h3>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div class="text-center p-4 bg-blue-50 rounded-lg">
                <div class="text-3xl font-bold text-blue-600">
                  <%= CreatorPulseWeb.format_number(@video.view_count) %>
                </div>
                <div class="text-sm text-gray-600 mt-1">Views</div>
              </div>
              <div class="text-center p-4 bg-green-50 rounded-lg">
                <div class="text-3xl font-bold text-green-600">
                  <%= CreatorPulseWeb.format_number(@video.like_count) %>
                </div>
                <div class="text-sm text-gray-600 mt-1">Likes</div>
              </div>
              <div class="text-center p-4 bg-purple-50 rounded-lg">
                <div class="text-3xl font-bold text-purple-600">
                  <%= CreatorPulseWeb.format_number(@video.comment_count) %>
                </div>
                <div class="text-sm text-gray-600 mt-1">Comments</div>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold mb-2">Description</h3>
            <div class="text-gray-700 whitespace-pre-wrap text-sm">
              <%= if @video.description do %>
                <%= @video.description %>
              <% else %>
                <span class="italic text-gray-500">No description available</span>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"channel_id" => _channel_id, "id" => id}, _session, socket) do
    channel = Videos.get_video!(id).channel

    {:ok,
     socket
     |> assign(:page_title, "Video Details")
     |> assign(:channel, channel)
     |> assign(:video, Videos.get_video!(id))}
  end
end
