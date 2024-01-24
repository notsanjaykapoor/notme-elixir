defmodule NotmeWeb.UserController do
  use NotmeWeb, :controller

  alias Notme.Model
  alias Notme.Service

  action_fallback NotmeWeb.FallbackController

  def index(conn, params) do
    users = Service.User.users_list(params)
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %Model.User{} = user} <- Service.User.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Service.User.user_get_by_id!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Service.User.user_get_by_id!(id)

    with {:ok, %Model.User{} = user} <- Service.User.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  @spec delete(any(), map()) :: any()
  def delete(conn, %{"id" => id}) do
    user = Service.User.user_get_by_id!(id)

    with {:ok, %Model.User{}} <- Service.User.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
