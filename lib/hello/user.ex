defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :mobile, :string
    field :state, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :mobile, :state, :user_id])
    |> validate_required([:email, :state, :user_id])
    |> validate_format(:user_id, ~r/^[a-z_0-9-]+$/)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:mobile)
    |> unique_constraint(:user_id)
  end
end
