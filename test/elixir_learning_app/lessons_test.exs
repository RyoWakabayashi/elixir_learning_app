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
        "version" => "1.0",
        "sections" => [
          %{
            "type" => "text",
            "content" => "Welcome to Elixir!"
          },
          %{
            "type" => "code_snippet",
            "language" => "elixir",
            "content" => "IO.puts(\"Hello, World!\")"
          }
        ],
        "objectives" => ["Learn basic syntax"],
        "prerequisites" => [],
        "estimated_time" => 15
      },
      initial_code: "# Write your code here",
      solution_code: "IO.puts(\"Hello, World!\")",
      evaluation_criteria: %{
        "type" => "output_match",
        "expected" => "Hello, World!"
      }
    }

    @update_attrs %{
      title: "Updated Introduction to Elixir",
      description: "Updated description"
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

    test "get_lesson_by_slug/1 returns nil for non-existent slug" do
      assert Lessons.get_lesson_by_slug("non-existent") == nil
    end

    test "create_lesson/1 with valid data creates a lesson" do
      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(@valid_attrs)
      assert lesson.title == "Introduction to Elixir"
      assert lesson.slug == "intro-to-elixir"
      assert lesson.category == "basics"
      assert lesson.difficulty == 1
      assert lesson.order == 1
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = lesson_fixture()
      assert {:ok, %Lesson{} = lesson} = Lessons.update_lesson(lesson, @update_attrs)
      assert lesson.title == "Updated Introduction to Elixir"
      assert lesson.description == "Updated description"
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

    test "list_lessons_by/1 filters lessons by category" do
      lesson1 = lesson_fixture(%{category: "basics", slug: "lesson-1"})
      lesson2 = lesson_fixture(%{category: "advanced", slug: "lesson-2"})

      assert Lessons.list_lessons_by(%{category: "basics"}) == [lesson1]
      assert Lessons.list_lessons_by(%{category: "advanced"}) == [lesson2]
    end

    test "list_lessons_by/1 filters lessons by difficulty" do
      lesson1 = lesson_fixture(%{difficulty: 1, slug: "lesson-1"})
      lesson2 = lesson_fixture(%{difficulty: 3, slug: "lesson-2"})

      assert Lessons.list_lessons_by(%{difficulty: 1}) == [lesson1]
      assert Lessons.list_lessons_by(%{difficulty: 3}) == [lesson2]
    end

    test "get_lessons_by_category/0 groups lessons by category" do
      lesson1 = lesson_fixture(%{category: "basics", slug: "lesson-1"})
      lesson2 = lesson_fixture(%{category: "advanced", slug: "lesson-2"})
      lesson3 = lesson_fixture(%{category: "basics", slug: "lesson-3", order: 2})

      result = Lessons.get_lessons_by_category()
      assert Map.keys(result) |> Enum.sort() == ["advanced", "basics"]

      assert result["basics"] |> Enum.map(& &1.id) |> Enum.sort() ==
               [lesson1.id, lesson3.id] |> Enum.sort()

      assert result["advanced"] == [lesson2]
    end

    test "get_lessons_by_difficulty/1 returns lessons of specific difficulty" do
      lesson1 = lesson_fixture(%{difficulty: 1, slug: "lesson-1"})
      lesson2 = lesson_fixture(%{difficulty: 3, slug: "lesson-2"})

      assert Lessons.get_lessons_by_difficulty(1) == [lesson1]
      assert Lessons.get_lessons_by_difficulty(3) == [lesson2]
      assert Lessons.get_lessons_by_difficulty(5) == []
    end

    test "get_next_lesson/1 returns next lesson by order" do
      lesson1 = lesson_fixture(%{category: "basics", order: 1, slug: "lesson-1"})
      lesson2 = lesson_fixture(%{category: "basics", order: 2, slug: "lesson-2"})
      lesson3 = lesson_fixture(%{category: "advanced", order: 1, slug: "lesson-3"})

      assert Lessons.get_next_lesson(lesson1) == lesson2
      assert Lessons.get_next_lesson(lesson2) == nil
      assert Lessons.get_next_lesson(lesson3) == nil
    end

    test "get_next_lesson/1 uses next_lesson_id when set" do
      lesson1 = lesson_fixture(%{category: "basics", order: 1, slug: "lesson-1"})
      _lesson2 = lesson_fixture(%{category: "basics", order: 2, slug: "lesson-2"})
      lesson3 = lesson_fixture(%{category: "advanced", order: 1, slug: "lesson-3"})

      # Update lesson1 to point to lesson3 as next
      {:ok, lesson1} = Lessons.update_lesson(lesson1, %{next_lesson_id: lesson3.slug})

      assert Lessons.get_next_lesson(lesson1) == lesson3
    end

    test "get_previous_lesson/1 returns previous lesson by order" do
      lesson1 = lesson_fixture(%{category: "basics", order: 1, slug: "lesson-1"})
      lesson2 = lesson_fixture(%{category: "basics", order: 2, slug: "lesson-2"})
      lesson3 = lesson_fixture(%{category: "advanced", order: 1, slug: "lesson-3"})

      assert Lessons.get_previous_lesson(lesson1) == nil
      assert Lessons.get_previous_lesson(lesson2) == lesson1
      assert Lessons.get_previous_lesson(lesson3) == nil
    end

    test "get_previous_lesson/1 uses prev_lesson_id when set" do
      lesson1 = lesson_fixture(%{category: "basics", order: 1, slug: "lesson-1"})
      _lesson2 = lesson_fixture(%{category: "basics", order: 2, slug: "lesson-2"})
      lesson3 = lesson_fixture(%{category: "advanced", order: 1, slug: "lesson-3"})

      # Update lesson3 to point to lesson1 as previous
      {:ok, lesson3} = Lessons.update_lesson(lesson3, %{prev_lesson_id: lesson1.slug})

      assert Lessons.get_previous_lesson(lesson3) == lesson1
    end

    test "get_categories/0 returns all unique categories" do
      lesson_fixture(%{category: "basics", slug: "lesson-1"})
      lesson_fixture(%{category: "advanced", slug: "lesson-2"})
      lesson_fixture(%{category: "basics", slug: "lesson-3"})

      categories = Lessons.get_categories()
      assert Enum.sort(categories) == ["advanced", "basics"]
    end

    test "get_difficulty_levels/0 returns all unique difficulty levels" do
      lesson_fixture(%{difficulty: 1, slug: "lesson-1"})
      lesson_fixture(%{difficulty: 3, slug: "lesson-2"})
      lesson_fixture(%{difficulty: 1, slug: "lesson-3"})

      levels = Lessons.get_difficulty_levels()
      assert Enum.sort(levels) == [1, 3]
    end

    test "list_lessons_paginated/1 returns paginated results" do
      # Create 5 lessons
      for i <- 1..5 do
        lesson_fixture(%{slug: "lesson-#{i}", order: i})
      end

      # Test first page
      result = Lessons.list_lessons_paginated(%{page: 1, page_size: 2})
      assert length(result.lessons) == 2
      assert result.total_count == 5
      assert result.page == 1
      assert result.page_size == 2
      assert result.total_pages == 3

      # Test second page
      result = Lessons.list_lessons_paginated(%{page: 2, page_size: 2})
      assert length(result.lessons) == 2
      assert result.page == 2

      # Test last page
      result = Lessons.list_lessons_paginated(%{page: 3, page_size: 2})
      assert length(result.lessons) == 1
      assert result.page == 3
    end

    test "lesson_exists?/1 returns true for existing lesson" do
      lesson = lesson_fixture()
      assert Lessons.lesson_exists?(lesson.slug) == true
    end

    test "lesson_exists?/1 returns false for non-existing lesson" do
      assert Lessons.lesson_exists?("non-existent") == false
    end
  end

  describe "content management" do
    test "create_lesson_with_content/7 creates lesson with structured content" do
      sections = [
        Lesson.text_section("Welcome to Elixir!"),
        Lesson.code_snippet_section("IO.puts(\"Hello, World!\")"),
        Lesson.task_section("Your Turn", "Write your first Elixir program")
      ]

      opts = [
        description: "Learn Elixir basics",
        objectives: ["Understand syntax", "Write first program"],
        prerequisites: ["basic-programming"],
        estimated_time: 20,
        initial_code: "# Write your code here",
        solution_code: "IO.puts(\"Hello, World!\")"
      ]

      assert {:ok, lesson} =
               Lessons.create_lesson_with_content(
                 "Introduction to Elixir",
                 "intro-elixir",
                 "basics",
                 1,
                 1,
                 sections,
                 opts
               )

      assert lesson.title == "Introduction to Elixir"
      assert lesson.slug == "intro-elixir"
      assert Lesson.get_content_version(lesson) == "1.0"
      assert length(Lesson.get_sections(lesson)) == 3
      assert Lesson.get_objectives(lesson) == ["Understand syntax", "Write first program"]
      assert Lesson.get_prerequisites(lesson) == ["basic-programming"]
      assert Lesson.get_estimated_time(lesson) == 20
    end

    test "update_lesson_content/3 updates content and increments version" do
      lesson = lesson_fixture()

      new_sections = [
        Lesson.text_section("Updated content"),
        Lesson.code_snippet_section("IO.puts(\"Updated!\")")
      ]

      assert {:ok, updated_lesson} = Lessons.update_lesson_content(lesson, new_sections)

      assert Lesson.get_content_version(updated_lesson) == "1.1"
      assert length(Lesson.get_sections(updated_lesson)) == 2
      assert Enum.at(Lesson.get_sections(updated_lesson), 0)["content"] == "Updated content"
    end

    test "update_lesson_content/3 with custom version" do
      lesson = lesson_fixture()

      new_sections = [Lesson.text_section("New content")]
      opts = [version: "2.0", objectives: ["New objective"]]

      assert {:ok, updated_lesson} = Lessons.update_lesson_content(lesson, new_sections, opts)

      assert Lesson.get_content_version(updated_lesson) == "2.0"
      assert Lesson.get_objectives(updated_lesson) == ["New objective"]
    end

    test "add_section_to_lesson/2 adds section to existing lesson" do
      lesson = lesson_fixture()
      original_sections_count = length(Lesson.get_sections(lesson))

      new_section = Lesson.text_section("Additional content")

      assert {:ok, updated_lesson} = Lessons.add_section_to_lesson(lesson, new_section)

      new_sections = Lesson.get_sections(updated_lesson)
      assert length(new_sections) == original_sections_count + 1
      assert List.last(new_sections) == new_section
    end

    test "remove_section_from_lesson/2 removes section by index" do
      sections = [
        Lesson.text_section("First"),
        Lesson.text_section("Second"),
        Lesson.text_section("Third")
      ]

      {:ok, lesson} =
        Lessons.create_lesson_with_content(
          "Test Lesson",
          "test-remove",
          "basics",
          1,
          1,
          sections
        )

      assert {:ok, updated_lesson} = Lessons.remove_section_from_lesson(lesson, 1)

      remaining_sections = Lesson.get_sections(updated_lesson)
      assert length(remaining_sections) == 2
      assert Enum.at(remaining_sections, 0)["content"] == "First"
      assert Enum.at(remaining_sections, 1)["content"] == "Third"
    end

    test "remove_section_from_lesson/2 returns error for invalid index" do
      lesson = lesson_fixture()

      assert {:error, :invalid_section_index} = Lessons.remove_section_from_lesson(lesson, 999)
      assert {:error, :invalid_section_index} = Lessons.remove_section_from_lesson(lesson, -1)
    end

    test "update_lesson_section/3 updates specific section" do
      sections = [
        Lesson.text_section("Original"),
        Lesson.text_section("Keep this")
      ]

      {:ok, lesson} =
        Lessons.create_lesson_with_content(
          "Test Lesson",
          "test-update-section",
          "basics",
          1,
          1,
          sections
        )

      updated_section = Lesson.text_section("Updated content")

      assert {:ok, updated_lesson} = Lessons.update_lesson_section(lesson, 0, updated_section)

      updated_sections = Lesson.get_sections(updated_lesson)
      assert Enum.at(updated_sections, 0)["content"] == "Updated content"
      assert Enum.at(updated_sections, 1)["content"] == "Keep this"
    end

    test "update_lesson_section/3 returns error for invalid index" do
      lesson = lesson_fixture()
      section = Lesson.text_section("New content")

      assert {:error, :invalid_section_index} =
               Lessons.update_lesson_section(lesson, 999, section)

      assert {:error, :invalid_section_index} = Lessons.update_lesson_section(lesson, -1, section)
    end

    test "get_lessons_with_prerequisite/1 finds lessons with specific prerequisite" do
      sections = [Lesson.text_section("Content")]

      {:ok, lesson1} =
        Lessons.create_lesson_with_content(
          "Lesson 1",
          "lesson-1",
          "basics",
          1,
          1,
          sections,
          prerequisites: ["intro-programming"]
        )

      {:ok, lesson2} =
        Lessons.create_lesson_with_content(
          "Lesson 2",
          "lesson-2",
          "basics",
          1,
          2,
          sections,
          prerequisites: ["advanced-concepts"]
        )

      {:ok, _lesson3} =
        Lessons.create_lesson_with_content(
          "Lesson 3",
          "lesson-3",
          "basics",
          1,
          3,
          sections,
          prerequisites: ["intro-programming", "basic-syntax"]
        )

      lessons_with_intro = Lessons.get_lessons_with_prerequisite("intro-programming")
      lesson_ids = Enum.map(lessons_with_intro, & &1.id) |> Enum.sort()

      assert length(lessons_with_intro) == 2
      assert lesson1.id in lesson_ids
      refute lesson2.id in lesson_ids
    end

    test "get_lessons_by_time_range/2 finds lessons within time range" do
      sections = [Lesson.text_section("Content")]

      {:ok, _lesson1} =
        Lessons.create_lesson_with_content(
          "Short Lesson",
          "short",
          "basics",
          1,
          1,
          sections,
          estimated_time: 10
        )

      {:ok, lesson2} =
        Lessons.create_lesson_with_content(
          "Medium Lesson",
          "medium",
          "basics",
          1,
          2,
          sections,
          estimated_time: 25
        )

      {:ok, _lesson3} =
        Lessons.create_lesson_with_content(
          "Long Lesson",
          "long",
          "basics",
          1,
          3,
          sections,
          estimated_time: 60
        )

      lessons_in_range = Lessons.get_lessons_by_time_range(15, 30)
      assert length(lessons_in_range) == 1
      assert hd(lessons_in_range).id == lesson2.id
    end

    test "validate_lesson_content/1 validates content structure" do
      valid_content = %{
        "version" => "1.0",
        "sections" => [
          %{"type" => "text", "content" => "Hello"}
        ]
      }

      invalid_content = %{
        "sections" => [
          %{"type" => "invalid", "content" => "Hello"}
        ]
      }

      assert :ok = Lessons.validate_lesson_content(valid_content)
      assert {:error, _message} = Lessons.validate_lesson_content(invalid_content)
    end
  end
end
