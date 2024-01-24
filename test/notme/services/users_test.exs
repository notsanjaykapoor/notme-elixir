defmodule Notme.UsersTest do
  use Notme.DataCase

  alias Notme.Service

  describe "users" do
    alias Notme.Model.User

    import Notme.UsersFixtures

    @invalid_attrs %{user_id: "UserA"}

    test "users_list/0 returns all users" do
      user = user_fixture()
      assert Service.User.users_list() == [user]
    end

    test "user_get_by_id!/1 returns the user with given id" do
      user = user_fixture()
      assert Service.User.user_get_by_id!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "user-1@gmail.com", state: "active", user_id: "user-1"}

      assert {:ok, %User{} = _user} = Service.User.create_user(valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Service.User.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{}

      assert {:ok, %User{} = _user} = Service.User.update_user(user, update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Service.User.update_user(user, @invalid_attrs)
      assert user == Service.User.user_get_by_id!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Service.User.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Service.User.user_get_by_id!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Service.User.change_user(user)
    end
  end
end
