defmodule Hello.Catalog.Variant do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "variants" do
    field :name, :string
    field :price, :integer
    field :tags, {:array, :string}

    belongs_to :product, Hello.Catalog.Prduct

    timestamps()
  end

  @doc false
  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [:name, :price, :product_id, :tags])
    |> validate_required([:name, :price, :product_id, :tags])
  end

end
