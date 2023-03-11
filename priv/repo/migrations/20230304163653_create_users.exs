defmodule Hello.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, size: 100, null: false, unique: true
      add :mobile, :string, size: 30, null: true, unique: true
      add :state, :string, size: 20, null: false
      add :user_id, :string, size: 100, null: false, unique: true

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:mobile])
    create unique_index(:users, [:user_id])
  end
end
