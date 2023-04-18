defmodule HelloWeb.Session do

  def user_handle_id(session) do
    user_handle = Map.get(session, "user_handle", "guest")
    user_id = Map.get(session, "user_id", 0)

    {user_handle, user_id}
  end

end
