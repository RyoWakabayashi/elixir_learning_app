defmodule ElixirLearningApp.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ElixirLearningApp.Lessons` context.
  """

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    default_content = %{
      "version" => "1.0",
      "sections" => [
        %{
          "type" => "text",
          "content" => "Test lesson content"
        }
      ],
      "objectives" => ["Test objective"],
      "estimated_time" => 15
    }

    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        title: "Test Lesson",
        slug: "test-lesson-#{System.unique_integer([:positive])}",
        description: "A test lesson",
        category: "basics",
        difficulty: 1,
        order: 1,
        content: default_content,
        initial_code: "# Test code",
        solution_code: "# Solution code",
        evaluation_criteria: %{"type" => "test"}
      })
      |> ElixirLearningApp.Lessons.create_lesson()

    lesson
  end
end
