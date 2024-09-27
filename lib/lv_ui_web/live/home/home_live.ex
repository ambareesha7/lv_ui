defmodule LvUiWeb.Live.HomeLive do
  require Logger
  use LvUiWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> assign(:org, AsyncResult.loading())
     |> start_async(:my_task, fn -> fetch_res() end)}
  end

  def render(assigns) do
    ~H"""
    <%!-- Home page --%>
    <div class="grid justify-center gap-2 py-20"></div>

    <div>
      <h1 class="text-brand py-4 flex justify-center text-3xl">
        LiveView
      </h1>
      <div class=" flex flex-col justify-center items-center text-2xl pb-10">
        <div>
          Build Kanban board with Drag & Drop feature,
          <br />changes should sync realtime with multiple browsers
        </div>
        <div>and use <span class="p-2 font-bold">Client hooks via phx-hook</span></div>
      </div>

      <%!-- async result here --%>
      <div class="flex justify-center text-2xl ">
        <%!-- <.async_result :let={org} assign={@org}>
          <:loading>
            <.show_loader />
          </:loading>
          <:failed :let={failure}>
            there was an error:
            <span class="text-brand px-2">
              <%= failure %>
            </span>
          </:failed>
          <%= if org do %>
            <%= org %>
          <% end %>
        </.async_result> --%>
      </div>
    </div>
    """
  end

  def fetch_res() do
    :timer.sleep(2000)
    {:ok, "My organization name here"}

    # {:error, "error reason here"}
  end

  def handle_async(:my_task, {:ok, {:ok, fetched_org}}, socket) do
    %{org: org} = socket.assigns
    {:noreply, assign(socket, :org, AsyncResult.ok(org, fetched_org))}
  end

  def handle_async(:my_task, {:ok, {:error, error}}, socket) do
    {:noreply,
     socket
     |> assign(:org, AsyncResult.failed(%AsyncResult{}, error))}
  end

  def handle_async(:my_task, {:exit, reason}, socket) do
    {:noreply, assign(socket, :org, AsyncResult.failed(%AsyncResult{}, {:exit, reason}))}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
