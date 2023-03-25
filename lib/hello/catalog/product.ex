defmodule Hello.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :merchant_id, :id
    field :name, :string
    field :options_count, :integer, virtual: true
    field :price, :integer
    field :variants_count, :integer, virtual: true
    field :views, :integer

    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:merchant_id, :name, :options_count, :price, :variants_count, :views])
    |> validate_required([:merchant_id, :name, :price, :views])
  end
end
