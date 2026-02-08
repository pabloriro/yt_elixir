defmodule CreatorPulseWeb.ChannelLive.Index do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Analytics

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Channels
        <:actions>
          <.button variant="primary" navigate={~p"/channels/new"}>
            <.icon name="hero-plus" /> New Channel
          </.button>
        </:actions>
      </.header>

      <.table
        id="channels"
        rows={@streams.channels}
        row_click={fn {_id, channel} -> JS.navigate(~p"/channels/#{channel}") end}
      >
        <:col :let={{_id, channel}} label="Youtube">{channel.youtube_id}</:col>
        <:col :let={{_id, channel}} label="Title">{channel.title}</:col>
        <:col :let={{_id, channel}} label="Thumbnail">{channel.thumbnail}</:col>
        <:col :let={{_id, channel}} label="Description">{channel.description}</:col>
        <:action :let={{_id, channel}}>
          <div class="sr-only">
            <.link navigate={~p"/channels/#{channel}"}>Show</.link>
          </div>
          <.link navigate={~p"/channels/#{channel}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, channel}}>
          <.link
            phx-click={JS.push("delete", value: %{id: channel.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Channels")
     |> stream(:channels, list_channels())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    channel = Analytics.get_channel!(id)
    {:ok, _} = Analytics.delete_channel(channel)

    {:noreply, stream_delete(socket, :channels, channel)}
  end
  
  defp list_channels() do
    Analytics.list_channels()
  end
end
