defmodule CreatorPulseWeb.ChannelLive.Show do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Analytics

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Channel {@channel.id}
        <:subtitle>This is a channel record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/channels"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button navigate={~p"/channels/#{@channel}/videos"}>
            <.icon name="hero-video-camera" /> Videos
          </.button>
          <.button variant="primary" navigate={~p"/channels/#{@channel}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit channel
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Youtube">{@channel.youtube_id}</:item>
        <:item title="Title">{@channel.title}</:item>
        <:item title="Thumbnail">{@channel.thumbnail}</:item>
        <:item title="Description">{@channel.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Channel")
     |> assign(:channel, Analytics.get_channel!(id))}
  end
end
