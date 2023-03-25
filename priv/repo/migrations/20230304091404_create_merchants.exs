defmodule Hello.Repo.Migrations.CreateMerchants do
  use Ecto.Migration

  def change do
    create table(:merchants) do
      add :name, :string
      add :slug, :string
      add :state, :string

      timestamps()
    end
  end
end
