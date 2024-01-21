defmodule Notme.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :merchant_id, references(:merchants, on_delete: :delete_all)
      add :name, :string, null: false
      add :price, :integer, null: false
      add :views, :integer, default: 0, null: false

      timestamps()
    end

    create unique_index(:products, [:name, :merchant_id])
  end
end
