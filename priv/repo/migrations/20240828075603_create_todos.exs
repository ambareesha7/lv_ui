defmodule LvUi.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :done, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:todos, [:name])
  end
end
