defmodule LvUiWeb.Live.HomeLive do
  use LvUiWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:org, AsyncResult.loading())
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(text: "text here")}
  end

  def render(assigns) do
    ~H"""
    <%!-- Home page --%>
    <div class="flex flex-col gap-2 py-20">
      <%!-- <button class="relative hover:bg-teal-300 bg-teal-50 p-2 w-1/4" popovertarget="popover1">
        show popup
        <div popover id="popover1" class="absolute bg-teal-200 p-5">
          <p>
            pop-over test
            pop-over test
          </p>
        </div>
      </button> --%>
    </div>
    <div>
      <%!-- <button class="phx-modal-close" phx-click={show_modal()}>show</button> --%>
    </div>
    <div>
      <.modal1 text={@text} />
    </div>
    <div>
      <h1 class="text-brand py-4 flex justify-center text-3xl">
        Liveview
      </h1>
      <h1 class=" flex justify-center items-center text-2xl">
        Live Chatting, Authentication, Forms,
        Streams, PubSub,
        JavaScript interoperability, Auto_scrolling, Datetime formating
      </h1>
      <p>
        <%!-- <%= Faker.Lorem.paragraph(5..10) %> --%>
      </p>
      <%!-- async result here --%>
      <%!-- <.async_result :let={org} assign={@org}>
        <:loading>
          <.show_loader />
        </:loading>
        <:failed :let={_failure}>there was an error loading the organization</:failed>
        <%= if org do %>
          <%= org.name %>
        <% else %>
          You don't have an organization yet.
        <% end %>
      </.async_result> --%>
    </div>
    """
  end

  alias Phoenix.LiveView.JS

  def fetch_res() do
    :timer.sleep(2000)
    %{name: "org name here"}
  end

  def handle_async(:my_task, {:ok, fetched_org}, socket) do
    %{org: org} = socket.assigns
    {:noreply, assign(socket, :org, AsyncResult.ok(org, fetched_org))}
  end

  def handle_async(:my_task, {:exit, reason}, socket) do
    %{org: org} = socket.assigns
    {:noreply, assign(socket, :org, AsyncResult.failed(org, {:exit, reason}))}
  end

  def hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal")
    |> JS.hide(transition: "fade-out-scale", to: "#modal-content")
  end

  def show_modal(js \\ %JS{}) do
    js
    |> JS.show(transition: "fade-out", to: "#modal")
    |> JS.show(transition: "fade-out-scale", to: "#modal-content")
  end

  def modal1(assigns) do
    ~H"""
    <div id="modal" class="phx-modal hidden bg-red-200 p-20 w-x-full " phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content"
        phx-click-away={hide_modal()}
        phx-window-keydown={hide_modal()}
        phx-key="escape"
      >
        <button class="phx-modal-close" phx-click={hide_modal()}>✖</button>
        <p><%= @text %></p>
      </div>
    </div>
    """
  end

  def handle_event("create_assets", params, socket) do
    {:noreply, socket |> put_flash(:info, "received-items: #{inspect(params)}")}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
