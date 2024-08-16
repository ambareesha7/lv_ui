defmodule LvUi.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias LvUi.Rooms.Room
  alias LvUi.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :message, :string
    field :sender_name, :string
    belongs_to :room, Room
    belongs_to :sender, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :sender_id, :sender_name])
    |> validate_required([:message])
  end
end
