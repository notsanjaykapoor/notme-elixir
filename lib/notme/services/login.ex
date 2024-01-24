defmodule Notme.Service.Login do

  def password_validate(password, auth) do
    if auth != "" and password == auth do
      {:ok, "ok"}
    else
      {:error, "password invalid"}
    end
  end

end
