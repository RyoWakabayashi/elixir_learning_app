defmodule ElixirLearningApp.LessonsTest do
  use ElixirLearningApp.DataCase

  alias ElixirLearningApp.Lessons
  alias ElixirLearningApp.Lessons.Lesson

  describe "lessons" do
    @valid_attrs %{
      title: "Introduction to Elixir",
      slug: "intro-to-elixir",
      description: "Learn the basics of Elixir",
      category: "basics",
      difficulty: 1,
      order: 1,
      content: %{
        "sections" => [
          %{
            "title" => "What is Elixir?",
            "content" => "Elixir is a dynamic, functional language..."
          }
        ]
      },
      initial_code: "IO.puts(\"Hello, world!\")",
      solution_code: "IO.puts(\"Hello, world!\")",
      evaluation_criteria: %{
        "type" => "output_match",
        "expected" => "Hello, world!\n"
      }
    }
    @update_attrs %{
      title: "Updated Introduction to Elixir",
      difficulty: 2
    }
    @invalid_attrs %{
      title: nil,
      slug: nil,
      category: nil,
      difficulty: nil,
      order: nil,
      content: nil
    }

    def lesson_fixture(attrs \\ %{}) do
      {:ok, lesson} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Lessons.create_lesson()

      lesson
    end

    test "list_lessons/0 returns all lessons" do
      lesson = lesson_fixture()
      assert Lessons.list_lessons() == [lesson]
    end

    test "get_lesson!/1 returns the lesson with given id" do
      lesson = lesson_fixture()
      assert Lessons.get_lesson!(lesson.id) == lesson
    end

    test "get_lesson_by_slug/1 returns the lesson with given slug" do
      lesson = lesson_fixture()
      assert Lessons.get_lesson_by_slug(lesson.slug) == lesson
    end

    test "create_lesson/1 with valid data creates a lesson" do
      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(@valid_attrs)
      assert lesson.title == "Introduction to Elixir"
      assert lesson.slug == "intro-to-elixir"
      assert lesson.category == "basics"
      assert lesson.difficulty == 1
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = lesson_fixture()
      assert {:ok, %Lesson{} = lesson} = Lessons.update_lesson(lesson, @update_attrs)
      assert lesson.title == "Updated Introduction to Elixir"
      assert lesson.difficulty == 2
    end

    test "update_lesson/2 with invalid data returns error changeset" do
      lesson = lesson_fixture()
      assert {:error, %Ecto.Changeset{}} = Lessons.update_lesson(lesson, @invalid_attrs)
      assert lesson == Lessons.get_lesson!(lesson.id)
    end

    test "delete_lesson/1 deletes the lesson" do
      lesson = lesson_fixture()
      assert {:ok, %Lesson{}} = Lessons.delete_lesson(lesson)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = lesson_fixture()
      assert %Ecto.Changeset{} = Lessons.change_lesson(lesson)
    end
  end
end
