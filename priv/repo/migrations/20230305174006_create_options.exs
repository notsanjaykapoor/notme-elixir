defmodule Notme.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :merchant_id, references(:merchants, on_delete: :delete_all)
      add :name, :string, null: false
      add :pkg_count, :integer
      add :pkg_size, :string
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps()
    end

    create index(:options, [:product_id])
    create unique_index(:options, [:name, :product_id])
  end
end
