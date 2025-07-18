defmodule ElixirLearningApp.Users.UserProgressManager do
  @moduledoc """
  The UserProgressManager context.
  """

  import Ecto.Query, warn: false
  alias ElixirLearningApp.Repo
  alias ElixirLearningApp.Users.UserProgress

  @doc """
  Returns the list of user progress for a specific user.

  ## Examples

      iex> list_user_progress("user123")
      [%UserProgress{}, ...]

  """
  def list_user_progress(user_id) do
    UserProgress
    |> where([up], up.user_id == ^user_id)
    |> preload(:lesson)
    |> Repo.all()
  end

  @doc """
  Gets a single user progress entry.

  Returns nil if the UserProgress does not exist.

  ## Examples

      iex> get_user_progress("user123", 42)
      %UserProgress{}

      iex> get_user_progress("user123", 999)
      nil

  """
  def get_user_progress(user_id, lesson_id) do
    UserProgress
    |> where([up], up.user_id == ^user_id and up.lesson_id == ^lesson_id)
    |> preload(:lesson)
    |> Repo.one()
  end

  @doc """
  Creates or updates a user progress entry.

  ## Examples

      iex> upsert_user_progress(%{user_id: "user123", lesson_id: 42})
      {:ok, %UserProgress{}}

      iex> upsert_user_progress(%{user_id: nil, lesson_id: 42})
      {:error, %Ecto.Changeset{}}

  """
  def upsert_user_progress(attrs) do
    case get_user_progress(attrs.user_id, attrs.lesson_id) do
      nil ->
        %UserProgress{}
        |> UserProgress.changeset(attrs)
        |> Repo.insert()

      user_progress ->
        user_progress
        |> UserProgress.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Marks a lesson as completed for a user.

  ## Examples

      iex> complete_lesson("user123", 42, "final code")
      {:ok, %UserProgress{}}

  """
  def complete_lesson(user_id, lesson_id, last_code \\ nil) do
    attrs = %{
      completed: true,
      completed_at: DateTime.utc_now(),
      last_code: last_code
    }

    case get_user_progress(user_id, lesson_id) do
      nil ->
        %UserProgress{}
        |> UserProgress.changeset(%{user_id: user_id, lesson_id: lesson_id})
        |> UserProgress.complete_changeset(attrs)
        |> Repo.insert()

      user_progress ->
        user_progress
        |> UserProgress.complete_changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Records an attempt for a lesson by a user.

  ## Examples

      iex> record_attempt("user123", 42, "attempted code")
      {:ok, %UserProgress{}}

  """
  def record_attempt(user_id, lesson_id, last_code \\ nil) do
    case get_user_progress(user_id, lesson_id) do
      nil ->
        %UserProgress{}
        |> UserProgress.changeset(%{
          user_id: user_id,
          lesson_id: lesson_id,
          attempts: 1,
          last_code: last_code
        })
        |> Repo.insert()

      user_progress ->
        user_progress
        |> UserProgress.attempt_changeset(%{
          attempts: user_progress.attempts + 1,
          last_code: last_code
        })
        |> Repo.update()
    end
  end

  @doc """
  Gets the user's progress summary.

  ## Examples

      iex> get_progress_summary("user123")
      %{completed: 5, total: 10, categories: %{"basics" => %{completed: 3, total: 5}}}

  """
  def get_progress_summary(user_id) do
    # Get all lessons
    lessons = ElixirLearningApp.Lessons.list_lessons()
    total_lessons = length(lessons)

    # Get completed lessons for the user
    completed_lessons_query =
      from up in UserProgress,
        where: up.user_id == ^user_id and up.completed == true,
        select: up.lesson_id

    completed_lesson_ids = Repo.all(completed_lessons_query)
    completed_lessons_count = length(completed_lesson_ids)

    # Group lessons by category
    lessons_by_category = Enum.group_by(lessons, & &1.category)

    # Calculate completion by category
    categories =
      lessons_by_category
      |> Enum.map(fn {category, cat_lessons} ->
        completed_in_category =
          cat_lessons
          |> Enum.count(&(&1.id in completed_lesson_ids))

        {category, %{completed: completed_in_category, total: length(cat_lessons)}}
      end)
      |> Map.new()

    %{
      completed: completed_lessons_count,
      total: total_lessons,
      categories: categories
    }
  end
end
