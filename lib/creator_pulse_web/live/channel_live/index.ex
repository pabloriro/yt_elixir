defmodule CreatorPulseWeb.ChannelLive.Index do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Analytics

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:actions>
          <%= if @live_action == :index do %>
            <.button variant="primary" navigate={~p"/channels/new"}>
              <.icon name="hero-plus" /> New Channel
            </.button>
          <% else %>
            <.button navigate={~p"/channels"}>
              <.icon name="hero-arrow-left" /> Back to Channels
            </.button>
          <% end %>
        </:actions>
      </.header>

      <%= if @live_action in [:new, :edit] do %>
        <.form for={@form} id="channel-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:youtube_id]} type="text" label="Youtube ID" phx-blur="fetch_youtube" />
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:thumbnail]} type="text" label="Thumbnail" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Channel</.button>
            <.button navigate={~p"/channels"}>Cancel</.button>
          </footer>
        </.form>
      <% else %>
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
            <.link navigate={~p"/channels/#{channel}/videos"}>Videos</.link>
          </:action>
          <:action :let={{_id, channel}}>
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
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Channels")
     |> assign(:form, to_form(Analytics.change_channel(%CreatorPulse.Analytics.Channel{})))
     |> stream(:channels, list_channels())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    channel = Analytics.get_channel!(id)

    socket
    |> assign(:page_title, "Edit Channel")
    |> assign(:channel, channel)
    |> assign(:form, to_form(Analytics.change_channel(channel)))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Channel")
    |> assign(:channel, %CreatorPulse.Analytics.Channel{})
    |> assign(:form, to_form(Analytics.change_channel(%CreatorPulse.Analytics.Channel{})))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Channels")
    |> stream(:channels, list_channels(), reset: true)
  end

  @impl true
  def handle_event("validate", %{"channel" => channel_params}, socket) do
    changeset =
      socket.assigns.channel
      |> Analytics.change_channel(channel_params)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("fetch_youtube", %{"youtube_id" => youtube_id}, socket) do
    case CreatorPulse.YoutubeAPI.get_channel_info(youtube_id) do
      {:ok, info} ->
        changeset =
          socket.assigns.channel
          |> Analytics.change_channel(info)

        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "No se pudo encontrar el canal")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    channel = Analytics.get_channel!(id)
    {:ok, _} = Analytics.delete_channel(channel)

    {:noreply, stream_delete(socket, :channels, channel)}
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    save_channel(socket, socket.assigns.live_action, channel_params)
  end

  defp save_channel(socket, :edit, channel_params) do
    case Analytics.update_channel(socket.assigns.channel, channel_params) do
      {:ok, _channel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Channel updated successfully")
         |> push_navigate(to: ~p"/channels")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_channel(socket, :new, channel_params) do
    case Analytics.create_channel(channel_params) do
      {:ok, _channel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Channel created successfully")
         |> push_navigate(to: ~p"/channels")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp list_channels() do
    Analytics.list_channels()
  end
end
