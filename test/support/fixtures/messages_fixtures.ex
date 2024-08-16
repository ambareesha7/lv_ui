defmodule LvUi.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LvUi.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        message: "some message",
        name: "some name"
      })
      |> LvUi.Messages.create_message()

    message
  end
end
