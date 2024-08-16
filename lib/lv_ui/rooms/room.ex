defmodule LvUi.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias LvUi.Accounts.User
  alias LvUi.Messages.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :name, :string
    has_many :messages, Message
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
  end
end
