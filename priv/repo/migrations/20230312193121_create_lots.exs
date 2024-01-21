defmodule Notme.Repo.Migrations.CreateLots do
  use Ecto.Migration

  def change do
    create table(:lots) do
      # add :location_id, references(:locations, on_delete: :nothing)
      add :location_id, :integer, default: 0
      add :qavail, :integer, default: 0
      add :qsold, :integer, default: 0
      add :item_id, references(:items, on_delete: :nothing)

      timestamps()
    end

    create index(:lots, [:location_id])
    create index(:lots, [:item_id])
  end
end
