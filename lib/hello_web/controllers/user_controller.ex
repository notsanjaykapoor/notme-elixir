defmodule HelloWeb.UserController do
  use HelloWeb, :controller

  alias Hello.Catalog.User
  alias Hello.UserService

  action_fallback HelloWeb.FallbackController

  def index(conn, _params) do
    users = UserService.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- UserService.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserService.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserService.get_user!(id)

    with {:ok, %User{} = user} <- UserService.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserService.get_user!(id)

    with {:ok, %User{}} <- UserService.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
