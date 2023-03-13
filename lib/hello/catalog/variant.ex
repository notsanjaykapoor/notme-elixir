defmodule Hello.Catalog.Variant do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Catalog.Product

  schema "variants" do
    field :lots, {:array, :integer}
    field :name, :string
    field :price, :integer
    field :tags, {:array, :string}
    field :qavail, :integer
    field :qsold, :integer

    belongs_to :product, Product

    timestamps()
  end

  @doc false
  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [:lots, :name, :price, :product_id, :qavail, :qsold, :tags])
    |> validate_required([:name, :price, :product_id, :tags])
  end

end
