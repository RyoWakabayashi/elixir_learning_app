defmodule ElixirLearningApp.Lessons.Lesson do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirLearningApp.Users.UserProgress

  schema "lessons" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :category, :string
    field :difficulty, :integer
    field :order, :integer
    field :content, :map
    field :initial_code, :string
    field :solution_code, :string
    field :evaluation_criteria, :map
    field :next_lesson_id, :string
    field :prev_lesson_id, :string

    has_many :user_progress, UserProgress

    timestamps()
  end

  @required_fields ~w(title slug category difficulty order content)a
  @optional_fields ~w(description initial_code solution_code evaluation_criteria next_lesson_id prev_lesson_id)a

  @doc """
  Creates a changeset for a lesson.
  """
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:difficulty, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:order, greater_than_or_equal_to: 1)
    |> unique_constraint(:slug)
  end
end
