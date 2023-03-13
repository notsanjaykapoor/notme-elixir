defmodule Hello.Catalog.Lot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lots" do
    field :location_id, :integer
    field :qavail, :integer
    field :qsold, :integer
    field :variant_id, :id

    timestamps()
  end

  @doc false
  def changeset(lot, attrs) do
    lot
    |> cast(attrs, [:qavail, :qsold, :location_id, :variant_id])
    |> validate_required([:variant_id])
  end
end
