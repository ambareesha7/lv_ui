defmodule LvUi.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  # mix phx.gen.context Todos Todo todos name:string:unique done:boolean
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :name, :string
    field :done, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :done])
    |> validate_required([:name, :done])
    |> unique_constraint(:name)
  end
end
