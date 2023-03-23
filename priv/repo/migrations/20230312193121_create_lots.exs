defmodule Hello.Repo.Migrations.CreateLots do
  use Ecto.Migration

  def change do
    create table(:lots) do
      # add :location_id, references(:locations, on_delete: :nothing)
      add :location_id, :integer, default: 0
      add :qavail, :integer, default: 0
      add :qsold, :integer, default: 0
      add :variant_id, references(:variants, on_delete: :nothing)

      timestamps()
    end

    create index(:lots, [:location_id])
    create index(:lots, [:variant_id])
  end
end
