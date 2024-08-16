defmodule LvUiWeb.Live.ChattingLive do
  use LvUiWeb, :live_view
  require Logger
  alias LvUi.Messages.Message
  alias LvUi.Messages
  alias LvUi.Rooms
  alias LvUiWeb.Presence

  def render(assigns) do
    ~H"""
    <div class="">
      <b> People</b>
      <span class="text-green-300 font-bold animate-pulse">
        online:
      </span>
      <ul>
        <%= for name <- @presence do %>
          <li class="odd:text-teal-500 even:text-teal-700">
            <%= get_name(name) %>
          </li>
        <% end %>
      </ul>
    </div>
    <div>
      <div class="font-bold pb-2 ">
        Room name: <%= @room.name %>
      </div>
      <div
        phx-update="stream"
        phx-viewport-top="prev-page"
        phx-viewport-bottom="next-page"
        class="border-solid border-2 border-sky-500 rounded-md hover:bg-sky-100
        overflow-y-auto h-80 snap-y snap-mandatory"
        id="mbox"
      >
        <div id="songs-empty" class="only:block hidden px-4">
          No Messages yet
        </div>
        <div
          :for={{dom_id, value} <- @streams.messages}
          value={"#{value.message}"}
          id={dom_id}
          class=" px-2 py-1"
        >
          <div class="flex justify-between">
            <div>
              <%= show_user(@current_user.id, value) %>:
            </div>
            <div>
              <%= format_date(value.inserted_at) %>
            </div>
          </div>
          <p class="px-4">
            <%= value.message %>
          </p>
        </div>
      </div>

      <.simple_form for={@form} id="chatting_form" phx-submit="save" class="bg-blue-200">
        <.input field={@form[:message]} id="message" type="text" placeholder="type message" required />
        <:actions>
          <.button phx-disable-with="Sending message..." class="w-full bg-green-400">Send</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @presence_topic "liveview_chat_presence"

  def mount(_params, _session, socket) do
    changeset = Messages.change_message(%Message{})
    user = socket.assigns.current_user

    if connected?(socket) do
      subscribe()
      {:ok, _} = Presence.track(self(), @presence_topic, user.id, %{name: user.email})
      Phoenix.PubSub.subscribe(LvUi.PubSub, @presence_topic)
    end

    {
      :ok,
      socket
      |> assign(page_title: get_page_title(__MODULE__))
      |> stream(:messages, [])
      |> assign(presence: get_presence_names())
      |> assign(room: %{})
      |> assign(form: to_form(changeset))
    }
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    room = Rooms.get_room!(id)
    messages = Messages.list_messages(room.id)

    {
      :noreply,
      socket
      |> assign(room: room)
      |> stream(:messages, messages)
    }
  end

  def handle_event("save", %{"message" => user_params} = params, socket) do
    user = socket.assigns.current_user
    room = socket.assigns.room
    user_params = Map.merge(user_params, %{"sender_id" => user.id, "sender_name" => user.email})

    case Messages.create_message(room, user_params) do
      {:ok, msg} ->
        notify({:ok, msg}, :message_created)

        {:noreply, push_event(socket, "clear-input", %{id: "message"})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      _ ->
        {:noreply, socket |> put_flash(:info, "error: #{inspect(params)}")}
    end
  end

  def handle_event(_anything, _params, socket) do
    {:noreply, socket}
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply,
     socket
     |> stream_insert(:messages, message)
     |> push_event("clear-input", %{id: "message"})}
  end

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, assign(socket, presence: get_presence_names())}
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(LvUi.PubSub, "liveview_chat")
  end

  def notify({:ok, message}, event) do
    Phoenix.PubSub.broadcast(LvUi.PubSub, "liveview_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}

  defp get_presence_names() do
    Presence.list(@presence_topic)
    |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)
  end

  defp show_user(id, msg) do
    if id == msg.sender_id do
      "You"
    else
      get_name(msg.sender_name)
    end
  end

  defp get_name(name) when not is_nil(name) when name != "" do
    if String.contains?(name, "@") do
      name
      |> String.split("@")
      |> List.first()
    else
      name
    end
  end

  defp format_date(datetime) do
    case Timex.format(Timex.local(datetime), "%l:%M:%S %P %d-%b-%y", :strftime) do
      {:ok, date} ->
        date

      _any ->
        datetime
    end
  end
end
