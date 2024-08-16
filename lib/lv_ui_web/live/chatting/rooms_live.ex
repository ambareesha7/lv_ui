defmodule LvUiWeb.Live.RoomsLive do
  require Logger
  alias LvUi.Rooms
  alias LvUi.Rooms.Room
  use LvUiWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="grid">
      Created Rooms:
      <%= if not is_nil(@rooms) do %>
        <div :for={value <- @rooms} class=" p-2 odd:bg-violet-100  even:bg-teal-50 ">
          <.link class="px-10" href={~p"/rooms/#{value.id}?name=#{value.name}"}>
            <%= value.name %>
          </.link>
        </div>
      <% end %>
      <.simple_form for={@form} id="room_form" phx-submit="save" phx-change="validate">
        <.input
          field={@form[:name]}
          type="text"
          label="Room name"
          placeholder="type room name"
          required
        />

        <:actions>
          <.button phx-disable-with="Creating room..." class="w-full">Create room</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Rooms.change_room(%Room{})

    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(rooms: Rooms.list_rooms())
     |> assign(form: to_form(changeset))}
  end

  def handle_event("validate", %{"room" => _data} = _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"room" => user_params} = params, socket) do
    user = socket.assigns.current_user

    case Rooms.create_room(user, user_params) do
      {:ok, room} ->
        {
          :noreply,
          socket
          |> assign(rooms: Rooms.list_rooms())
          |> put_flash(:info, "room created: #{inspect(room.name)}")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      _ ->
        {:noreply, socket |> put_flash(:info, "error: #{inspect(params)}")}
    end
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
