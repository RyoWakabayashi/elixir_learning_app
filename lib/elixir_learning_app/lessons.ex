defmodule ElixirLearningApp.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias ElixirLearningApp.I18n.TranslationManager
  alias ElixirLearningApp.Lessons.Lesson
  alias ElixirLearningApp.Repo

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

  @doc """
  Gets lessons organized by category.

  ## Examples

      iex> get_lessons_by_category()
      %{"basics" => [%Lesson{}, ...], "advanced" => [%Lesson{}, ...]}

  """
  def get_lessons_by_category do
    Lesson
    |> order_by([l], [l.category, l.order, l.id])
    |> Repo.all()
    |> Enum.group_by(& &1.category)
  end

  @doc """
  Gets lessons filtered by difficulty level.

  ## Examples

      iex> get_lessons_by_difficulty(1)
      [%Lesson{}, ...]

  """
  def get_lessons_by_difficulty(difficulty) when is_integer(difficulty) do
    Lesson
    |> where([l], l.difficulty == ^difficulty)
    |> order_by([l], [l.order, l.id])
    |> Repo.all()
  end

  @doc """
  Gets the next lesson in sequence based on category and order.

  ## Examples

      iex> get_next_lesson(%Lesson{category: "basics", order: 1})
      %Lesson{}

      iex> get_next_lesson(%Lesson{category: "basics", order: 999})
      nil

  """
  def get_next_lesson(%Lesson{} = lesson) do
    # First try to find next lesson by next_lesson_id if set
    case lesson.next_lesson_id do
      nil ->
        # Fall back to finding next lesson by category and order
        Lesson
        |> where([l], l.category == ^lesson.category and l.order > ^lesson.order)
        |> order_by([l], [l.order, l.id])
        |> limit(1)
        |> Repo.one()

      next_id ->
        get_lesson_by_slug(next_id) || Repo.get(Lesson, next_id)
    end
  end

  @doc """
  Gets the previous lesson in sequence based on category and order.

  ## Examples

      iex> get_previous_lesson(%Lesson{category: "basics", order: 2})
      %Lesson{}

      iex> get_previous_lesson(%Lesson{category: "basics", order: 1})
      nil

  """
  def get_previous_lesson(%Lesson{} = lesson) do
    # First try to find previous lesson by prev_lesson_id if set
    case lesson.prev_lesson_id do
      nil ->
        # Fall back to finding previous lesson by category and order
        Lesson
        |> where([l], l.category == ^lesson.category and l.order < ^lesson.order)
        |> order_by([l], desc: l.order, desc: l.id)
        |> limit(1)
        |> Repo.one()

      prev_id ->
        get_lesson_by_slug(prev_id) || Repo.get(Lesson, prev_id)
    end
  end

  @doc """
  Gets all available categories.

  ## Examples

      iex> get_categories()
      ["basics", "intermediate", "advanced"]

  """
  def get_categories do
    Lesson
    |> select([l], l.category)
    |> distinct(true)
    |> order_by([l], l.category)
    |> Repo.all()
  end

  @doc """
  Gets all available difficulty levels.

  ## Examples

      iex> get_difficulty_levels()
      [1, 2, 3, 4, 5]

  """
  def get_difficulty_levels do
    Lesson
    |> select([l], l.difficulty)
    |> distinct(true)
    |> order_by([l], l.difficulty)
    |> Repo.all()
  end

  @doc """
  Gets lessons with pagination support.

  ## Examples

      iex> list_lessons_paginated(%{page: 1, page_size: 10})
      %{lessons: [%Lesson{}, ...], total_count: 25, page: 1, page_size: 10}

  """
  def list_lessons_paginated(opts \\ %{}) do
    page = Map.get(opts, :page, 1)
    page_size = Map.get(opts, :page_size, 20)
    filters = Map.get(opts, :filters, %{})

    query =
      Lesson
      |> filter_by_category(filters)
      |> filter_by_difficulty(filters)
      |> order_by([l], [l.order, l.id])

    total_count = Repo.aggregate(query, :count, :id)

    lessons =
      query
      |> limit(^page_size)
      |> offset(^((page - 1) * page_size))
      |> Repo.all()

    %{
      lessons: lessons,
      total_count: total_count,
      page: page,
      page_size: page_size,
      total_pages: ceil(total_count / page_size)
    }
  end

  @doc """
  Checks if a lesson exists by slug.

  ## Examples

      iex> lesson_exists?("intro-to-elixir")
      true

      iex> lesson_exists?("nonexistent")
      false

  """
  def lesson_exists?(slug) when is_binary(slug) do
    Lesson
    |> where([l], l.slug == ^slug)
    |> Repo.exists?()
  end

  @doc """
  Gets a lesson with translations applied for the specified locale.

  ## Examples

      iex> get_lesson_with_translations("intro-to-elixir", "ja")
      %Lesson{title: "Elixir入門", ...}

  """
  def get_lesson_with_translations(slug, locale) when is_binary(slug) and is_binary(locale) do
    case get_lesson_by_slug(slug) do
      nil -> nil
      lesson -> apply_lesson_translations(lesson, locale)
    end
  end

  @doc """
  Applies translations to a lesson for the specified locale.

  ## Examples

      iex> apply_lesson_translations(lesson, "ja")
      %Lesson{title: "Elixir入門", ...}

  """
  def apply_lesson_translations(%Lesson{} = lesson, locale) do
    translations = TranslationManager.get_lesson_translations(locale, lesson.slug)

    lesson
    |> apply_basic_translations(translations)
    |> apply_content_translations(translations, locale)
  end

  defp apply_basic_translations(lesson, translations) do
    %{
      lesson
      | title: Map.get(translations, "title", lesson.title),
        description: Map.get(translations, "description", lesson.description)
    }
  end

  defp apply_content_translations(lesson, translations, locale) do
    translated_content = Map.get(translations, "content")

    case translated_content do
      nil ->
        lesson

      content when is_map(content) ->
        # Merge translated content with original content, preserving code examples
        merged_content = merge_lesson_content(lesson.content, content, locale)
        %{lesson | content: merged_content}

      _ ->
        lesson
    end
  end

  defp merge_lesson_content(original_content, translated_content, _locale) do
    # Start with original content structure
    base_content = original_content || %{}

    # Apply translations to specific fields
    base_content
    |> Map.put(
      "objectives",
      Map.get(translated_content, "objectives", Map.get(base_content, "objectives", []))
    )
    |> Map.put(
      "sections",
      merge_sections(
        Map.get(base_content, "sections", []),
        Map.get(translated_content, "sections", [])
      )
    )
    |> Map.put("version", Map.get(base_content, "version", "1.0"))
    |> Map.put("estimated_time", Map.get(base_content, "estimated_time"))
    |> Map.put(
      "prerequisites",
      Map.get(translated_content, "prerequisites", Map.get(base_content, "prerequisites", []))
    )
  end

  defp merge_sections(original_sections, translated_sections)
       when is_list(original_sections) and is_list(translated_sections) do
    original_sections
    |> Enum.with_index()
    |> Enum.map(fn {section, index} ->
      translated_section = Enum.at(translated_sections, index, %{})
      merge_section(section, translated_section)
    end)
  end

  defp merge_sections(original_sections, _), do: original_sections

  defp merge_section(original_section, translated_section)
       when is_map(original_section) and is_map(translated_section) do
    case original_section["type"] do
      "code_snippet" ->
        # For code snippets, only translate title and keep original code
        original_section
        |> Map.put("title", Map.get(translated_section, "title", original_section["title"]))

      "text" ->
        # For text sections, translate content and title
        original_section
        |> Map.put("content", Map.get(translated_section, "content", original_section["content"]))
        |> Map.put("title", Map.get(translated_section, "title", original_section["title"]))

      "task" ->
        # For task sections, translate title, description, and hints
        original_section
        |> Map.put("title", Map.get(translated_section, "title", original_section["title"]))
        |> Map.put(
          "description",
          Map.get(translated_section, "description", original_section["description"])
        )
        |> Map.put("hints", Map.get(translated_section, "hints", original_section["hints"]))

      _ ->
        # For unknown types, merge all fields except code-related ones
        Map.merge(original_section, translated_section)
    end
  end

  defp merge_section(original_section, _), do: original_section

  @doc """
  Creates or updates a lesson translation.

  ## Examples

      iex> create_lesson_translation("intro-to-elixir", "ja", %{
        title: "Elixir入門",
        description: "Elixirの基本を学びましょう"
      })
      {:ok, %Translation{}}

  """
  def create_lesson_translation(lesson_slug, locale, translations)
      when is_binary(lesson_slug) and is_binary(locale) do
    key = "lesson.#{lesson_slug}"

    TranslationManager.create_translation(%{
      locale: locale,
      key: key,
      content: translations
    })
  end

  @doc """
  Updates a lesson translation.

  ## Examples

      iex> update_lesson_translation("intro-to-elixir", "ja", %{
        title: "Elixir入門（更新版）"
      })
      {:ok, %Translation{}}

  """
  def update_lesson_translation(lesson_slug, locale, translations)
      when is_binary(lesson_slug) and is_binary(locale) do
    key = "lesson.#{lesson_slug}"

    case TranslationManager.get_translation(locale, key) do
      nil ->
        create_lesson_translation(lesson_slug, locale, translations)

      translation ->
        merged_content = Map.merge(translation.content, translations)

        TranslationManager.update_translation(translation, %{
          content: merged_content
        })
    end
  end

  @doc """
  Gets all available translations for a lesson.

  ## Examples

      iex> get_lesson_translations("intro-to-elixir")
      %{
        "en" => %{title: "Introduction to Elixir", ...},
        "ja" => %{title: "Elixir入門", ...}
      }

  """
  def get_lesson_translations(lesson_slug) when is_binary(lesson_slug) do
    key = "lesson.#{lesson_slug}"
    supported_locales = TranslationManager.get_supported_locales()

    supported_locales
    |> Enum.map(fn locale ->
      case TranslationManager.get_translation(locale, key) do
        nil -> {locale, %{}}
        translation -> {locale, translation.content}
      end
    end)
    |> Map.new()
  end

  # Content Management Functions

  @doc """
  Creates a lesson with structured content.

  ## Examples

      iex> create_lesson_with_content("Introduction", "intro", "basics", 1, 1, sections)
      {:ok, %Lesson{}}

  """
  def create_lesson_with_content(title, slug, category, difficulty, order, sections, opts \\ []) do
    content = Lesson.build_content(sections, opts)

    attrs =
      %{
        title: title,
        slug: slug,
        category: category,
        difficulty: difficulty,
        order: order,
        content: content,
        description: Keyword.get(opts, :description),
        initial_code: Keyword.get(opts, :initial_code),
        solution_code: Keyword.get(opts, :solution_code),
        evaluation_criteria: Keyword.get(opts, :evaluation_criteria)
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    create_lesson(attrs)
  end

  @doc """
  Updates lesson content while preserving version history.

  ## Examples

      iex> update_lesson_content(lesson, new_sections)
      {:ok, %Lesson{}}

  """
  def update_lesson_content(%Lesson{} = lesson, sections, opts \\ []) do
    current_version = Lesson.get_content_version(lesson)
    new_version = Keyword.get(opts, :version, increment_version(current_version))

    new_content = Lesson.build_content(sections, Keyword.put(opts, :version, new_version))

    update_lesson(lesson, %{content: new_content})
  end

  @doc """
  Adds a section to an existing lesson.

  ## Examples

      iex> add_section_to_lesson(lesson, text_section)
      {:ok, %Lesson{}}

  """
  def add_section_to_lesson(%Lesson{} = lesson, section) do
    current_sections = Lesson.get_sections(lesson)
    new_sections = current_sections ++ [section]

    update_lesson_content(lesson, new_sections)
  end

  @doc """
  Removes a section from a lesson by index.

  ## Examples

      iex> remove_section_from_lesson(lesson, 1)
      {:ok, %Lesson{}}

  """
  def remove_section_from_lesson(%Lesson{} = lesson, section_index)
      when is_integer(section_index) do
    current_sections = Lesson.get_sections(lesson)

    if section_index >= 0 and section_index < length(current_sections) do
      new_sections = List.delete_at(current_sections, section_index)
      update_lesson_content(lesson, new_sections)
    else
      {:error, :invalid_section_index}
    end
  end

  @doc """
  Updates a specific section in a lesson.

  ## Examples

      iex> update_lesson_section(lesson, 0, updated_section)
      {:ok, %Lesson{}}

  """
  def update_lesson_section(%Lesson{} = lesson, section_index, updated_section)
      when is_integer(section_index) do
    current_sections = Lesson.get_sections(lesson)

    if section_index >= 0 and section_index < length(current_sections) do
      new_sections = List.replace_at(current_sections, section_index, updated_section)
      update_lesson_content(lesson, new_sections)
    else
      {:error, :invalid_section_index}
    end
  end

  @doc """
  Gets lessons that have a specific prerequisite.

  ## Examples

      iex> get_lessons_with_prerequisite("basic-syntax")
      [%Lesson{}, ...]

  """
  def get_lessons_with_prerequisite(prerequisite_slug) when is_binary(prerequisite_slug) do
    # This is a complex query since prerequisites are stored in JSON
    # We'll use a simple approach for now
    Lesson
    |> Repo.all()
    |> Enum.filter(fn lesson ->
      prerequisite_slug in Lesson.get_prerequisites(lesson)
    end)
  end

  @doc """
  Gets lessons by estimated completion time range.

  ## Examples

      iex> get_lessons_by_time_range(10, 30)
      [%Lesson{}, ...]

  """
  def get_lessons_by_time_range(min_time, max_time)
      when is_integer(min_time) and is_integer(max_time) do
    Lesson
    |> Repo.all()
    |> Enum.filter(fn lesson ->
      case Lesson.get_estimated_time(lesson) do
        nil -> false
        time -> time >= min_time and time <= max_time
      end
    end)
  end

  @doc """
  Validates lesson content structure without saving.

  ## Examples

      iex> validate_lesson_content(content_map)
      :ok

      iex> validate_lesson_content(invalid_content)
      {:error, "validation error message"}

  """
  def validate_lesson_content(content) do
    changeset =
      Lesson.changeset(%Lesson{}, %{
        title: "Test",
        slug: "test",
        category: "test",
        difficulty: 1,
        order: 1,
        content: content
      })

    if changeset.valid? do
      :ok
    else
      {:error, changeset.errors[:content] || "Invalid content structure"}
    end
  end

  # Helper function to increment version numbers
  defp increment_version(version) when is_binary(version) do
    case String.split(version, ".") do
      [major, minor] ->
        case {Integer.parse(major), Integer.parse(minor)} do
          {{maj, ""}, {min, ""}} -> "#{maj}.#{min + 1}"
          _ -> "#{version}.1"
        end

      [major] ->
        case Integer.parse(major) do
          {maj, ""} -> "#{maj + 1}.0"
          _ -> "#{version}.1"
        end

      _ ->
        "#{version}.1"
    end
  end

  defp increment_version(_), do: "1.1"
end
