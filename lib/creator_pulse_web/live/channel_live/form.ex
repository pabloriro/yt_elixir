defmodule CreatorPulseWeb.ChannelLive.Form do
  use CreatorPulseWeb, :live_view

  alias CreatorPulse.Analytics
  alias CreatorPulse.Analytics.Channel

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage channel records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="channel-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:youtube_id]} type="text" label="Youtube" phx-blur="fetch_youtube" />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:thumbnail]} type="text" label="Thumbnail" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Channel</.button>
          <.button navigate={return_path(@return_to, @channel)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    channel = Analytics.get_channel!(id)

    socket
    |> assign(:page_title, "Edit Channel")
    |> assign(:channel, channel)
    |> assign(:form, to_form(Analytics.change_channel(channel)))
  end

  defp apply_action(socket, :new, _params) do
    channel = %Channel{}

    socket
    |> assign(:page_title, "New Channel")
    |> assign(:channel, channel)
    |> assign(:form, to_form(Analytics.change_channel(channel)))
  end

  @impl true
  def handle_event("fetch_youtube", %{"youtube_id" => id}, socket) do
    case CreatorPulse.YoutubeAPI.get_channel_info(id) do
      {:ok, info} ->
        # Aquí es donde ocurre la magia: actualizamos los datos del formulario
        changeset = 
          socket.assigns.channel
          |> CreatorPulse.Analytics.change_channel(info)
          
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "No se pudo encontrar el canal")}
    end
  end

  def handle_event("save", %{"channel" => channel_params}, socket) do
    save_channel(socket, socket.assigns.live_action, channel_params)
  end

  defp save_channel(socket, :edit, channel_params) do
    case Analytics.update_channel(socket.assigns.channel, channel_params) do
      {:ok, channel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Channel updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, channel))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  defp save_channel(socket, :new, channel_params) do
    case Analytics.create_channel(channel_params) do
      {:ok, channel} ->
        {:noreply,
         socket
         |> put_flash(:info, "Channel created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, channel))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _channel), do: ~p"/channels"
  defp return_path("show", channel), do: ~p"/channels/#{channel}"
end
