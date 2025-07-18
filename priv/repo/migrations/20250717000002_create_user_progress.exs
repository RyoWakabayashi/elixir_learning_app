defmodule ElixirLearningApp.Repo.Migrations.CreateUserProgress do
  use Ecto.Migration

  def change do
    create table(:user_progress) do
      add :user_id, :string, null: false
      add :lesson_id, references(:lessons, column: :id, on_delete: :delete_all), null: false
      add :completed, :boolean, default: false
      add :attempts, :integer, default: 0
      add :last_code, :text
      add :completed_at, :utc_datetime

      timestamps()
    end

    create index(:user_progress, [:user_id])
    create index(:user_progress, [:lesson_id])
    create unique_index(:user_progress, [:user_id, :lesson_id])
  end
end
