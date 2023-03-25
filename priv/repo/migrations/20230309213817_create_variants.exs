defmodule Hello.Repo.Migrations.CreateVariants do
  use Ecto.Migration

  def change do
    create table(:variants) do
      # add :loc_ids, {:array, :integer}, default: []
      # add :loc_slugs, {:array, :string}, default: []
      # add :lot_ids, {:array, :integer}, default: []
      add :loc_name, :string, null: false
      add :lot_id, :string, null: false
      add :merchant_id, references(:merchants, on_delete: :delete_all)
      add :name, :string, null: false
      add :option_id, references(:options, on_delete: :delete_all)
      add :price, :integer, null: false
      add :product_id, references(:products, on_delete: :delete_all)
      add :qavail, :integer, default: 0
      add :qsold, :integer, default: 0
      add :tags, {:array, :string}, default: []

      timestamps()
    end

    create index(:variants, [:option_id])
    create index(:variants, [:product_id])
    create unique_index(:variants, [:name, :option_id, :product_id])
  end
end
