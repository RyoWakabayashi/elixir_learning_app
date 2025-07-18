defmodule ElixirLearningApp.Users.UserProgress do
  @moduledoc """
  Schema for tracking user progress through lessons, including completion status and code attempts.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirLearningApp.Lessons.Lesson

  schema "user_progress" do
    field :user_id, :string
    field :completed, :boolean, default: false
    field :attempts, :integer, default: 0
    field :last_code, :string
    field :completed_at, :utc_datetime

    belongs_to :lesson, Lesson

    timestamps()
  end

  @required_fields ~w(user_id lesson_id)a
  @optional_fields ~w(completed attempts last_code completed_at)a

  @doc """
  Creates a changeset for user progress.
  """
  def changeset(user_progress, attrs) do
    user_progress
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:attempts, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:lesson_id)
    |> unique_constraint([:user_id, :lesson_id])
  end

  @doc """
  Creates a changeset for marking a lesson as completed.
  """
  def complete_changeset(user_progress, attrs) do
    user_progress
    |> cast(attrs, [:completed, :completed_at, :last_code])
    |> validate_required([:completed, :completed_at])
  end

  @doc """
  Creates a changeset for updating the attempt count and last code.
  """
  def attempt_changeset(user_progress, attrs) do
    user_progress
    |> cast(attrs, [:attempts, :last_code])
    |> validate_required([:attempts])
  end
end
