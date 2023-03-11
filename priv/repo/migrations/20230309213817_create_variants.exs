defmodule Hello.Repo.Migrations.CreateVariants do
  use Ecto.Migration

  def change do
    create table(:variants) do
      add :price, :integer
      add :name, :string
      add :tags, {:array, :string}
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps()
    end

    create index(:variants, [:product_id])
    create unique_index(:variants, [:name])
  end
end
