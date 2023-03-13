defmodule Hello.Repo.Migrations.CreateLots do
  use Ecto.Migration

  def change do
    create table(:lots) do
      add :qavail, :integer, default: 0
      add :qsold, :integer, default: 0
      add :location_id, :integer, default: 0
      add :variant_id, references(:variants, on_delete: :nothing)

      timestamps()
    end

    create index(:lots, [:variant_id])
  end
end
