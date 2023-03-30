defmodule Hello.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
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
      add :sku, :string, null: false
      add :tags, {:array, :string}, default: []

      timestamps()
    end

    create index(:items, [:option_id])
    create index(:items, [:product_id])
    create unique_index(:items, [:name, :option_id, :product_id])
  end
end
