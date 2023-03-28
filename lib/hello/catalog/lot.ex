defmodule Hello.Catalog.Lot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lots" do
    field :item_id, :id
    field :location_id, :integer
    field :qavail, :integer
    field :qsold, :integer

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
  def changeset(lot, attrs) do
    lot
    |> cast(attrs, [:item_id, :location_id, :qavail, :qsold])
    |> validate_required([:item_id, :location_id])
  end
end
