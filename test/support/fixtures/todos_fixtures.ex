defmodule LvUi.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LvUi.Todos` context.
  """

  @doc """
  Generate a unique todo name.
  """
  def unique_todo_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        done: true,
        name: unique_todo_name()
      })
      |> LvUi.Todos.create_todo()

    todo
  end
end
