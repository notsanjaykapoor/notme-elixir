defmodule Notme.Catalog.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :items_count, :integer, virtual: true
    field :name, :string
    field :pkg_count, :integer
    field :pkg_size, :string
    field :product_id, :id

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:name, :pkg_size, :pkg_count, :product_id, :items_count])
    |> validate_required([:name, :pkg_size, :pkg_count, :product_id])
  end
end
