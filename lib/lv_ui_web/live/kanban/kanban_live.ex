defmodule LvUiWeb.Live.KanbanLive do
  use LvUiWeb, :live_view
  require Logger
  import LvUiWeb.Live.KanbanComponents
  alias LvUi.KanbanBoard

  @topic "kanban_state"
  def mount(_params, _session, socket) do
    items =
      if connected?(socket) do
        Phoenix.PubSub.subscribe(LvUi.PubSub, @topic)
        KanbanBoard.get_state()
      else
        %{
          todo: [],
          in_progress: [],
          in_qa: [],
          done: []
        }
      end

    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))
     |> stream(:todo, items.todo)
     |> stream(:in_progress, items.in_progress)
     |> stream(:in_qa, items.in_qa)
     |> stream(:done, items.done)
     |> assign(group: "kanban_group")
     |> assign(form: to_form(%{}))}
  end

  def handle_event("reposition", params, socket) do
    {removed, _updated_items} = KanbanBoard.reposition(params)
    params = Map.merge(params, %{"change" => removed})
    Phoenix.PubSub.broadcast(LvUi.PubSub, @topic, {:update, params})

    {:noreply, socket}
  end

  def handle_event("add_item", %{"name" => name}, socket) do
    params = %{
      id: Ecto.UUID.generate(),
      name: name,
      tag: Faker.Cat.name(),
      body: Faker.Lorem.paragraph(1)
    }

    _added = KanbanBoard.create(params)
    Phoenix.PubSub.broadcast(LvUi.PubSub, @topic, {:new, params})

    {:noreply, socket}
  end

  def handle_event("delete", %{"item" => item, "list_id" => list_id} = _params, socket) do
    list_id = List.first(String.split(list_id, "-"))
    item = keys_to_atoms(item)
    params = %{"item" => item, "list_id" => list_id}
    _new_state = KanbanBoard.delete(params)
    Phoenix.PubSub.broadcast(LvUi.PubSub, @topic, {:delete, params})

    {:noreply, socket}
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "handle_event: #{inspect(params)}")}
  end

  def handle_info({:new, params}, socket) do
    {:noreply, stream_insert(socket, :todo, params, at: 0)}
  end

  def handle_info({:delete, params}, socket) do
    {
      :noreply,
      socket
      |> stream_delete(String.to_existing_atom(params["list_id"]), params["item"])
    }
  end

  def handle_info({:update, params}, socket) do
    {
      :noreply,
      socket
      |> stream_insert(String.to_existing_atom(params["to"]), params["change"],
        at: params["newIndex"]
      )
      |> stream_delete(String.to_existing_atom(params["from"]), params["change"])
    }
  end

  def handle_info(msg, socket) do
    Logger.warning(msg)
    {:noreply, socket}
  end

  def keys_to_atoms(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      Map.put(acc, String.to_existing_atom(k), v)
    end)
  end
end
