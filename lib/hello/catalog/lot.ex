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
    |> cast(attrs, [:qavail, :qsold, :location_id, :variant_id])
    |> validate_required([:location_id, :variant_id])
  end
end
