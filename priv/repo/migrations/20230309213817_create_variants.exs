defmodule Hello.Repo.Migrations.CreateVariants do
  use Ecto.Migration

  def change do
    create table(:variants) do
      add :lots, {:array, :integer}, default: []
      add :name, :string
      add :price, :integer
      add :product_id, references(:products, on_delete: :delete_all)
      add :qavail, :integer, default: 0
      add :qsold, :integer, default: 0
      add :tags, {:array, :string}, default: []

      timestamps()
    end

    create index(:variants, [:product_id])
    create unique_index(:variants, [:name])
  end
end
