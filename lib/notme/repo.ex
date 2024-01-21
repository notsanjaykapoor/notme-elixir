defmodule Notme.Repo do
  use Ecto.Repo,
    otp_app: :notme,
    adapter: Ecto.Adapters.Postgres
end
