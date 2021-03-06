defmodule LoadedBike.Repo.Migrations.CreateTour do
  use Ecto.Migration

  def change do
    create table(:tours) do
      add :user_id,     references(:users, on_delete: :delete_all), null: false

      add :title,             :string, null: false
      add :short_description, :string
      add :description,       :text

      add :is_completed, :boolean, null: false, default: false
      add :is_published, :boolean, null: false, default: false

      timestamps()
    end

    create index(:tours, [:user_id])
    create index(:tours, [:is_published])
  end
end
