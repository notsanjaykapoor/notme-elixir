defmodule Hello.Catalog.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Catalog.Option
  alias Hello.Catalog.Product

  schema "items" do
    field :loc_name, :string
    field :lot_id, :string
    field :merchant_id, :id
    field :name, :string
    field :price, :integer
    field :tags, {:array, :string}
    field :qavail, :integer
    field :qsold, :integer

    belongs_to :option, Option
    belongs_to :product, Product

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
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:loc_name, :lot_id, :merchant_id, :name, :option_id, :price, :product_id, :qavail, :qsold, :tags])
    |> validate_required([:loc_name, :lot_id, :merchant_id, :name, :option_id, :price, :product_id, :tags])
  end

end
