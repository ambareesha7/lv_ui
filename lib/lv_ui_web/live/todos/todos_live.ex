defmodule LvUiWeb.Live.TodosLive do
  use LvUiWeb, :live_view

  require Logger
  alias LvUi.Todos

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(page_title: get_page_title(__MODULE__))
      |> assign(page_bg: "bg-todo_bg")
      |> assign(add_todo: to_form(%{}))
      |> assign(errors: [])
      |> assign(:todos, Todos.list_todos())
    }
  end

  def handle_event("validate", _params, socket) do
    {:noreply, assign(socket, errors: [])}
  end

  def handle_event("save", %{"name" => _params} = params, socket) do
    save_todo(socket, :new, params)
  end

  def handle_event(
        "edit_todo",
        %{"todo_id" => id} = params,
        socket
      ) do
    todo = Todos.get_todo!(id)

    save_todo(assign(socket, edit_todo: todo), :edit, params)
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _result} = Todos.delete_todo(todo)

    {:noreply, assign(socket, :todos, Todos.list_todos())}
  end

  def handle_event(event, params, socket) do
    Logger.warning(inspect(params))

    {:noreply,
     socket
     |> put_flash(:info, "event: #{event}, value: #{inspect(params)}")}
  end

  defp save_todo(socket, :edit, todo_params) do
    case Todos.update_todo(socket.assigns.edit_todo, todo_params) do
      {:ok, _todo} ->
        {:noreply, assign(socket, :todos, Todos.list_todos())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, add_todo: to_form(changeset))}
    end
  end

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(todo_params) do
      {:ok, _todo} ->
        {:noreply, assign(socket, :todos, Todos.list_todos())}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = for {:name, {msg, _opts}} <- changeset.errors, do: msg

        {
          :noreply,
          socket
          |> assign(add_todo: to_form(changeset, action: :insert))
          |> assign(errors: errors)
        }
    end
  end

  def get_done_tasks(todos) do
    Enum.reduce(todos, 0, fn e, acc ->
      if e.done, do: acc + 1, else: acc
    end)
  end

  def get_parcentage(todos) do
    if length(todos) != 0 && get_done_tasks(todos) != 0 do
      get_done_tasks(todos) / length(todos) * 100
    else
      0
    end
  end
end
