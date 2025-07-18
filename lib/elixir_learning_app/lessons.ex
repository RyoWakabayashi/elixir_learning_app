defmodule ElixirLearningApp.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias ElixirLearningApp.Repo
  alias ElixirLearningApp.Lessons.Lesson

  @doc """
  Returns the list of lessons.

  ## Examples

      iex> list_lessons()
      [%Lesson{}, ...]

  """
  def list_lessons do
    Repo.all(Lesson)
  end

  @doc """
  Returns the list of lessons filtered by category and/or difficulty.

  ## Examples

      iex> list_lessons_by(%{category: "basics"})
      [%Lesson{}, ...]

  """
  def list_lessons_by(filters) do
    Lesson
    |> filter_by_category(filters)
    |> filter_by_difficulty(filters)
    |> order_by([l], [l.order, l.id])
    |> Repo.all()
  end

  defp filter_by_category(query, %{category: category}) when is_binary(category) do
    where(query, [l], l.category == ^category)
  end

  defp filter_by_category(query, _), do: query

  defp filter_by_difficulty(query, %{difficulty: difficulty}) when is_integer(difficulty) do
    where(query, [l], l.difficulty == ^difficulty)
  end

  defp filter_by_difficulty(query, _), do: query

  @doc """
  Gets a single lesson.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.

  ## Examples

      iex> get_lesson!(123)
      %Lesson{}

      iex> get_lesson!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson!(id), do: Repo.get!(Lesson, id)

  @doc """
  Gets a single lesson by slug.

  Returns nil if the Lesson does not exist.

  ## Examples

      iex> get_lesson_by_slug("intro-to-elixir")
      %Lesson{}

      iex> get_lesson_by_slug("nonexistent")
      nil

  """
  def get_lesson_by_slug(slug) when is_binary(slug) do
    Repo.get_by(Lesson, slug: slug)
  end

  @doc """
  Creates a lesson.

  ## Examples

      iex> create_lesson(%{field: value})
      {:ok, %Lesson{}}

      iex> create_lesson(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lesson.

  ## Examples

      iex> update_lesson(lesson, %{field: new_value})
      {:ok, %Lesson{}}

      iex> update_lesson(lesson, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson changes.

  ## Examples

      iex> change_lesson(lesson)
      %Ecto.Changeset{data: %Lesson{}}

  """
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end
end
