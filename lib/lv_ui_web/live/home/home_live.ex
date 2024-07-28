defmodule LvUiWeb.Live.HomeLive do
  use LvUiWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))}
  end

  def render(assigns) do
    ~H"""
    <%!-- Home page --%>
    <div class="flex flex-col gap-2">
      <button class="relative hover:bg-teal-300 bg-teal-50 p-2 w-1/4" popovertarget="popover1">
        show popup
        <div popover id="popover1" class="absolute bg-teal-200 p-5">
          <p>
            pop-over test
            pop-over test
          </p>
        </div>
      </button>
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
