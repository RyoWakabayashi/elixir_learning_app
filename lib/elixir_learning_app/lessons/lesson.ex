defmodule ElixirLearningApp.Lessons.Lesson do
  @moduledoc """
  Schema for lessons in the application, including content, difficulty, and navigation references.

  The content field supports a structured format with the following schema:

  ```
  %{
    "version" => "1.0",
    "sections" => [
      %{
        "type" => "text",
        "content" => "Introduction text with **markdown** support"
      },
      %{
        "type" => "code_snippet",
        "language" => "elixir",
        "content" => "IO.puts(\"Hello, World!\")",
        "title" => "Example: Hello World"
      },
      %{
        "type" => "task",
        "title" => "Your Turn",
        "description" => "Write a function that...",
        "hints" => ["Remember to use pattern matching", "Don't forget the return value"]
      }
    ],
    "objectives" => ["Learn basic syntax", "Understand pattern matching"],
    "prerequisites" => ["basic-elixir-syntax"],
    "estimated_time" => 15
  }
  ```
  """
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
    |> validate_content_structure()
    |> unique_constraint(:slug)
  end

  # Validates the content structure follows the expected schema.
  defp validate_content_structure(changeset) do
    case get_field(changeset, :content) do
      nil ->
        changeset

      content when is_map(content) ->
        case validate_content_map(content) do
          :ok -> changeset
          {:error, message} -> add_error(changeset, :content, message)
        end

      _ ->
        add_error(changeset, :content, "must be a valid content structure")
    end
  end

  defp validate_content_map(content) do
    case validate_version(content) do
      :ok -> validate_sections(content)
      error -> error
    end
  end

  defp validate_version(%{"version" => version}) when is_binary(version), do: :ok
  defp validate_version(_), do: {:error, "must include a version field"}

  defp validate_sections(%{"sections" => sections}) when is_list(sections) do
    sections
    |> Enum.with_index()
    |> Enum.reduce_while(:ok, fn {section, index}, :ok ->
      case validate_section(section) do
        :ok -> {:cont, :ok}
        {:error, message} -> {:halt, {:error, "section #{index}: #{message}"}}
      end
    end)
  end

  defp validate_sections(_), do: {:error, "must include a sections field with a list of sections"}

  # Validate text sections
  defp validate_section(%{"type" => "text", "content" => content}) when is_binary(content),
    do: :ok

  # Validate code snippet sections
  defp validate_section(%{"type" => "code_snippet", "language" => lang, "content" => content})
       when is_binary(lang) and is_binary(content),
       do: :ok

  # Validate task sections
  defp validate_section(%{"type" => "task", "title" => title, "description" => desc})
       when is_binary(title) and is_binary(desc),
       do: :ok

  # Allow unknown section types for flexibility (any section with a type field that's not a known type)
  defp validate_section(%{"type" => type}) when type not in ["text", "code_snippet", "task"],
    do: :ok

  # Reject sections without type or with invalid structure for known types
  defp validate_section(_), do: {:error, "invalid section structure"}

  @doc """
  Gets the content version for a lesson.
  """
  def get_content_version(%__MODULE__{content: %{"version" => version}}), do: version
  def get_content_version(_), do: "1.0"

  @doc """
  Gets the sections from lesson content.
  """
  def get_sections(%__MODULE__{content: %{"sections" => sections}}) when is_list(sections),
    do: sections

  def get_sections(_), do: []

  @doc """
  Gets the objectives from lesson content.
  """
  def get_objectives(%__MODULE__{content: %{"objectives" => objectives}})
      when is_list(objectives),
      do: objectives

  def get_objectives(_), do: []

  @doc """
  Gets the prerequisites from lesson content.
  """
  def get_prerequisites(%__MODULE__{content: %{"prerequisites" => prereqs}})
      when is_list(prereqs),
      do: prereqs

  def get_prerequisites(_), do: []

  @doc """
  Gets the estimated time from lesson content.
  """
  def get_estimated_time(%__MODULE__{content: %{"estimated_time" => time}}) when is_integer(time),
    do: time

  def get_estimated_time(_), do: nil

  @doc """
  Creates a new content structure with the given sections.
  """
  def build_content(sections, opts \\ []) do
    %{
      "version" => Keyword.get(opts, :version, "1.0"),
      "sections" => sections,
      "objectives" => Keyword.get(opts, :objectives),
      "prerequisites" => Keyword.get(opts, :prerequisites),
      "estimated_time" => Keyword.get(opts, :estimated_time)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) or (is_list(v) and Enum.empty?(v)) end)
    |> Enum.into(%{})
  end

  @doc """
  Creates a text section.
  """
  def text_section(content, opts \\ []) do
    %{
      "type" => "text",
      "content" => content
    }
    |> maybe_add_title(opts)
  end

  @doc """
  Creates a code snippet section.
  """
  def code_snippet_section(content, language \\ "elixir", opts \\ []) do
    %{
      "type" => "code_snippet",
      "language" => language,
      "content" => content
    }
    |> maybe_add_title(opts)
  end

  @doc """
  Creates a task section.
  """
  def task_section(title, description, opts \\ []) do
    %{
      "type" => "task",
      "title" => title,
      "description" => description
    }
    |> maybe_add_hints(opts)
  end

  defp maybe_add_title(section, opts) do
    case Keyword.get(opts, :title) do
      nil -> section
      title -> Map.put(section, "title", title)
    end
  end

  defp maybe_add_hints(section, opts) do
    case Keyword.get(opts, :hints) do
      nil -> section
      hints when is_list(hints) -> Map.put(section, "hints", hints)
      _ -> section
    end
  end
end
