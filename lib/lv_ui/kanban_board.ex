defmodule LvUi.KanbanBoard do
  require Logger
  use GenServer

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create(params) do
    GenServer.call(__MODULE__, {:create, params})
  end

  def delete(params) do
    GenServer.call(__MODULE__, {:delete, params})
  end

  def get_state() do
    GenServer.call(__MODULE__, :state)
  end

  def reposition(params) do
    GenServer.call(__MODULE__, {:reposition, params})
  end

  # Server (callbacks)

  @impl true
  def init(_init_arg) do
    num_of_items = 5

    state = %{
      todo: get_item(num_of_items),
      in_progress: get_item(num_of_items),
      in_qa: get_item(num_of_items),
      done: get_item(num_of_items)
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:create, element}, _from, state) do
    new_state = [element | state.todo]
    state = update_in(state.todo, fn _e -> new_state end)
    {:reply, state, state}
  end

  @impl true
  def handle_call({:delete, %{"item" => item, "list_id" => list_id}}, _from, state) do
    list_id = String.to_existing_atom(list_id)
    index = Enum.find_index(state[list_id], fn e -> e.id == item.id end)

    state =
      if index do
        update_in(state[list_id], fn e ->
          List.delete_at(e, index)
        end)
      else
        state
      end

    {:reply, state, state}
  end

  @impl true
  def handle_call({:reposition, params}, _from, state) do
    {removed, state} = reposition(state, params)
    {:reply, {removed, state}, state}
  end

  defp reposition(state, params) do
    from = String.to_existing_atom(params["from"])
    to = String.to_existing_atom(params["to"])

    {removed, removed_list} = List.pop_at(state[from], params["oldIndex"])

    state = update_in(state[from], fn _e -> removed_list end)
    state = update_in(state[to], fn e -> List.insert_at(e, params["newIndex"], removed) end)
    {removed, state}
  end

  defp get_item(number_of_items) do
    Enum.map(1..number_of_items, fn _e ->
      %{
        id: Ecto.UUID.generate(),
        name: "#{Faker.Commerce.product_name()}",
        tag: Faker.Cat.name(),
        body: Faker.Lorem.paragraph(2)
      }
    end)
  end
end
