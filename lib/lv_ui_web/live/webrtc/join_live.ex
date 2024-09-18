defmodule LvUiWeb.Live.JoinLive do
  require Logger
  use LvUiWeb, :live_view

  def render(assigns) do
    ~H"""
    <.form
      class="flex gap-2  m-4 justify-center items-center"
      for={@room}
      phx-submit="join_room"
      phx-change="validate"
      id="join_form"
    >
      <div class="grid gap-2 ">
        <.input
          name="user_name"
          label="User name:"
          value=""
          id="input_join"
          type="text"
          placeholder="add name"
        />
        <p :for={err <- @errors} :if={@errors != []} class="text-rose-400"><%= err %></p>
        <button type="submit" class="app-btn">
          Join
        </button>
      </div>
    </.form>

    <%!-- <div id="home" phx-hook="Home" class="h-full flex flex-row justify-center gap-6 lg:justify-end">
      <p id="join-error-message" class="w-full h-full text-brand/80 font-semibold hidden">
        Unable to join the room
      </p>
      <div id="videoplayer-wrapper" class="w-full h-full grid gap-2 p-2 auto-rows-fr grid-cols-1">
        <video id="videoplayer-local" class="rounded-xl w-full h-full object-cover" autoplay muted>
        </video>
      </div>
    </div> --%>
    """
  end

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(page_title: get_page_title(__MODULE__))
      |> assign(room: to_form(%{}))
      |> assign(errors: [])

      # |> assign(username: "")
    }
  end

  def handle_event("validate", %{"user_name" => user_name} = params, socket) do
    Logger.warning(validate: params)

    if user_name == "" do
      {:noreply, socket}
    else
      {:noreply, assign(socket, errors: [])}
    end
  end

  def handle_event("join_room", %{"user_name" => user_name} = _params, socket) do
    # Logger.warning(join: params)

    if user_name == "" do
      {:noreply, assign(socket, errors: ["required"])}
    else
      {:noreply, push_navigate(socket, to: "/room/#{user_name}")}
    end
  end

  def handle_event(anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Event: #{anything} Anything: #{inspect(params)}")}
  end
end
