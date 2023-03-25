defmodule Hello.Catalog.Merchant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchants" do
    field :name, :string
    field :products_count, :integer, virtual: true
    field :slug, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(merchant, attrs) do
    merchant
    |> cast(attrs, [:name, :products_count, :slug, :state])
    |> validate_required([:name, :slug, :state])
  end
end
