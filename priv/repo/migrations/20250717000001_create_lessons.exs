defmodule ElixirLearningApp.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :difficulty, :integer, null: false
      add :order, :integer, null: false
      add :content, :map, null: false
      add :initial_code, :text
      add :solution_code, :text
      add :evaluation_criteria, :map
      add :next_lesson_id, :string
      add :prev_lesson_id, :string

      timestamps()
    end

    create unique_index(:lessons, [:slug])
    create index(:lessons, [:category])
    create index(:lessons, [:difficulty])
    create index(:lessons, [:order])
  end
end
