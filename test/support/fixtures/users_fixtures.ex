defmodule Hello.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user-1@gmail.com",
        state: "active",
        user_id: "user-1",
      })
      |> Hello.Users.create_user()

    user
  end
end
