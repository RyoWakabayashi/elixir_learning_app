defmodule ElixirLearningApp.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :locale, :string, null: false
      add :key, :string, null: false
      add :content, :map, null: false

      timestamps()
    end

    create index(:translations, [:locale])
    create index(:translations, [:key])
    create unique_index(:translations, [:locale, :key])
  end
end
