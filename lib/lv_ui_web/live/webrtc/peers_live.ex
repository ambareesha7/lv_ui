defmodule LvUiWeb.Live.PeersLive do
  require Logger
  use LvUiWeb, :live_view

  alias LvUiWeb.Presence
  @presence_topic "presence_state"
  def render(assigns) do
    ~H"""
    <div>
      <h1>online: <%= length(@presence) %></h1>
      <%!-- <div id="video-streams">
        <%= for participant <- @participants do %>
          <div class="participant">
            <video id={"video-#{participant.id}"} autoplay></video>
            <p><%= participant.username %></p>
          </div>
        <% end %>
      </div> --%>
      <div id="home" phx-hook="Home" class="h-full flex flex-row justify-center gap-6 lg:justify-end">
        <p id="join-error-message" class="w-full h-full text-brand/80 font-semibold hidden">
          Unable to join the room
        </p>
        <div id="videoplayer-wrapper" class="w-full h-full grid gap-2 p-2 auto-rows-fr grid-cols-1">
          <div>
            <%!-- <p id="video_id">id</p> --%>
            <p id="video_id"><%= @user.email %></p>
            <video id="videoplayer-local" class="rounded-xl w-full h-full object-cover" autoplay muted>
            </video>
          </div>
        </div>
      </div>
      <div id="controls">
        <button phx-click="mute" class="app-btn">
          <%= if @muted, do: "Unmute", else: "Mute" %>
        </button>
        <button phx-click="toggle_video" class="app-btn" id="videoBtn">
          <%= if @video_off, do: "Video On", else: "Video Off" %>
        </button>
        <button phx-click="hang_up" class="app-btn">Hang Up</button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    if connected?(socket) do
      LvUiWeb.Endpoint.subscribe("peer:signalling")
      {:ok, _} = Presence.track(self(), @presence_topic, user.id, %{name: user.email})

      Phoenix.PubSub.subscribe(LvUi.PubSub, @presence_topic)
    end

    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(
       user: user,
       muted: false,
       video_off: false,
       participants: [],
       presence: []
     )}
  end

  def handle_event("mute", _params, socket) do
    muted = !socket.assigns.muted
    {:noreply, assign(socket, muted: muted)}
  end

  def handle_event("toggle_video", _params, socket) do
    video_off = !socket.assigns.video_off

    {:ok, state} = LvUi.Room.get_state()
    Logger.warning(state: inspect(state.peers))

    {
      :noreply,
      socket
      |> assign(video_off: video_off)
      # |> push_event("video", %{id: "message"})
    }
  end

  def handle_event("hang_up", _params, socket) do
    # Here you would add the logic to disconnect from the WebRTC session
    # redirect to home
    {:noreply, socket}
  end

  def handle_info(%{event: "new_peer", payload: %{peer_id: peer_id, username: username}}, socket) do
    participants = [%{id: peer_id, username: username} | socket.assigns.participants]
    {:noreply, assign(socket, participants: participants)}
  end

  def handle_info(%{event: "peer_left", payload: %{peer_id: peer_id}}, socket) do
    participants = Enum.reject(socket.assigns.participants, fn p -> p.id == peer_id end)
    {:noreply, assign(socket, participants: participants)}
  end

  def handle_info(%{event: "mute", payload: %{peer_id: peer_id, muted: muted}}, socket) do
    participants =
      Enum.map(socket.assigns.participants, fn
        p when p.id == peer_id -> %{p | muted: muted}
        p -> p
      end)

    {:noreply, assign(socket, participants: participants)}
  end

  def handle_info(
        %{event: "toggle_video", payload: %{peer_id: peer_id, video_off: video_off}},
        socket
      ) do
    participants =
      Enum.map(socket.assigns.participants, fn
        p when p.id == peer_id -> %{p | video_off: video_off}
        p -> p
      end)

    {:noreply, assign(socket, participants: participants)}
  end

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, assign(socket, presence: get_presence_names())}
  end

  def handle_info(any, socket) do
    Logger.warning(any: inspect(any))

    {:noreply, socket}
  end

  defp get_presence_names() do
    Presence.list(@presence_topic)
    |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)
  end
end
