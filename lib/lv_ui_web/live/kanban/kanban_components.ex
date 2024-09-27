defmodule LvUiWeb.Live.KanbanComponents do
  use Phoenix.Component
  import LvUiWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :group, :string, required: true
  attr :items, :list, required: true
  attr :list_id, :string, required: true

  def kanban_colm(assigns) do
    ~H"""
    <div class=" ">
      <div
        class="bg-blue-100 font-bold rounded-md shadow-sm px-0 py-1 px-6
        w-full flex items-center justify-center"
        id={"#{@list_id}_headind"}
      >
        <%= String.upcase(@list_id) %>
      </div>
      <div
        id={@list_id}
        phx-hook="Sortable"
        data-list_id={@list_id}
        data-group={@group}
        group={@group}
        class="flex flex-col gap-1 p-2 w-full  mt-1 border-2 border-gray-100
        hover:border-2 hover:border-teal-200"
        phx-update="stream"
      >
        <.cards items={@items} />
      </div>
    </div>
    """
  end

  attr :items, :list, required: true

  def cards(assigns) do
    ~H"""
    <div
      :for={{id, item} <- @items}
      value={"#{item.name}"}
      id={id}
      class="inline-block px-3"
      data-id={item.id}
    >
      <div class="w-54 h-54 max-w-xs max-h-xs overflow-hidden rounded-lg shadow-md bg-white
      hover:border-2 hover:border-teal-400 transition-shadow duration-300 ease-in-out p-4">
        <div class="grid justify-items-stretch font-bold">
          <h3 class="flex items-center justify-center font-bold">
            <%= item.name %>
          </h3>
          <%!-- :if={!String.starts_with?(id, "done")} --%>
          <button
            class="flex justify-self-end hover:text-rose-700 text-rose-400 "
            phx-click={JS.push("delete", value: %{item: item, list_id: id})}
          >
            <.icon name="hero-trash" class="" />
          </button>
        </div>
        <.add_dummy_element tag={item.tag} body={item.body} />
      </div>
    </div>
    """
  end

  def add_dummy_element(assigns) do
    ~H"""
    <div class=" flex flex-cols justify-start gap-1">
      <p class={["px-4 py-2 text-xs bg-sky-50"]}>
        <%= @tag %>
      </p>
    </div>
    <p><%= @body %></p>
    """
  end
end
