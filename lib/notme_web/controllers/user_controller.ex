defmodule NotmeWeb.UserController do
  use NotmeWeb, :controller

  alias Notme.Catalog.User
  alias Notme.UserService

  action_fallback NotmeWeb.FallbackController

  def index(conn, params) do
    users = UserService.users_list(params)
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
    user = UserService.user_get_by_id!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserService.user_get_by_id!(id)

    with {:ok, %User{} = user} <- UserService.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserService.user_get_by_id!(id)

    with {:ok, %User{}} <- UserService.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end