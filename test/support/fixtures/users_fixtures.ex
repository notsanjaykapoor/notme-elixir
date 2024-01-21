defmodule Notme.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Notme.Users` context.
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
      |> Notme.UserService.create_user()

    user
  end
end
