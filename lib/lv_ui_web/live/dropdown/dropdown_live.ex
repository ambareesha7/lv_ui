defmodule LvUiWeb.Live.DropdownLive do
  use LvUiWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(page_title: get_page_title(__MODULE__))
      |> assign(
        dropdown_items: ["Dashboard", "Left", "Right", "Settings", "Sign-out"],
        dropdown_items2: Enum.map(1..20, fn e -> "number #{inspect(e)}" end),
        selected1: nil,
        selected2: nil
      )
      # |> start_async(:my_task, fn -> fetch_res() end)
    }
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <%!-- dropdowns --%>
      <div>
        <h4 class="mb-5 p-2 bg-red-100 flex items-center justify-center">
          Dropdowns
        </h4>
        <div class="flex gap-2">
          <%!-- dropdown - 1 --%>
          <div class="relative flex items-start">
            <button
              class=" hover:bg-violet-100 active:bg-violet-700 focus:bg-violet-100
       justify-center items-center p-0 "
              phx-click={JS.toggle(to: "#dropdown1", in: "fade-in-scale", out: "fade-out-scale")}
              phx-click-away={JS.hide(to: "#dropdown1")}
              phx-keydown={JS.hide(to: "#dropdown1")}
              phx-key="escape"
            >
              <div class="flex">
                <span class="px-2"><%= @selected1 || "Select" %></span>
                <%!-- hero icons--%>
                <.icon name="hero-chevron-down" class="p-0" />
              </div>
            </button>
          </div>
          <div id="dropdown1" class="absolute mt-[2%] hidden bg-violet-100 rounded-lg py-2">
            <div
              :for={value <- @dropdown_items}
              value={"item #{value}"}
              phx-click={JS.push("add", value: %{name1: value})}
              class=" p-2 hover:bg-violet-500 active:bg-violet-700"
            >
              <%= value %>
            </div>
          </div>
          <%!-- dropdown - 2 --%>
          <div class="relative flex items-start justify-end ">
            <span class="px-2 "><%= @selected2 || "Select" %></span>
            <button
              class=" hover:bg-violet-100 active:bg-violet-700 focus:bg-violet-100
       justify-center items-center p-0 "
              phx-click={JS.toggle(to: "#dropdown2", in: "fade-in-scale", out: "fade-out-scale")}
              phx-click-away={JS.hide(to: "#dropdown2")}
              phx-keydown={JS.hide(to: "#dropdown2")}
              phx-key="escape"
            >
              <%!-- chevron-down ellipsis-vertical--%>
              <.icon name="hero-ellipsis-vertical" class="p-0" />
            </button>

            <div
              id="dropdown2"
              class="absolute mt-[30%] overflow-y-auto h-48 hidden bg-violet-100 rounded-lg py-2"
            >
              <div
                :for={value <- @dropdown_items2}
                value={"item #{value}"}
                phx-click={JS.push("add", value: %{name2: value})}
                class=" p-2 hover:bg-violet-500 active:bg-violet-700"
              >
                <%= value %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("add", %{"name1" => a} = _params, socket) do
    {:noreply,
     socket
     |> assign(selected1: a)
     |> put_flash(:info, "dropdown1: #{inspect(a)}")}
  end

  def handle_event("add", %{"name2" => a} = _params, socket) do
    {:noreply,
     socket
     |> assign(selected2: a)
     |> put_flash(:info, "dropdown2: #{inspect(a)}")}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
