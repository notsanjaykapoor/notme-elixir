defmodule Hello.UsersTest do
  use Hello.DataCase

  alias Hello.UserService

  describe "users" do
    alias Hello.Catalog.User

    import Hello.UsersFixtures

    @invalid_attrs %{user_id: "UserA"}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert UserService.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserService.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "user-1@gmail.com", state: "active", user_id: "user-1"}

      assert {:ok, %User{} = _user} = UserService.create_user(valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserService.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{}

      assert {:ok, %User{} = _user} = UserService.update_user(user, update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserService.update_user(user, @invalid_attrs)
      assert user == UserService.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserService.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserService.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserService.change_user(user)
    end
  end
end
