defmodule ElixirLearningApp.Lessons.LessonTest do
  use ElixirLearningApp.DataCase

  alias ElixirLearningApp.Lessons.Lesson

  describe "content structure validation" do
    @valid_content %{
      "version" => "1.0",
      "sections" => [
        %{
          "type" => "text",
          "content" => "Introduction to Elixir"
        },
        %{
          "type" => "code_snippet",
          "language" => "elixir",
          "content" => "IO.puts(\"Hello, World!\")",
          "title" => "Example"
        },
        %{
          "type" => "task",
          "title" => "Your Turn",
          "description" => "Write a function that prints hello"
        }
      ],
      "objectives" => ["Learn basic syntax"],
      "prerequisites" => ["basic-programming"],
      "estimated_time" => 15
    }

    @valid_attrs %{
      title: "Test Lesson",
      slug: "test-lesson",
      category: "basics",
      difficulty: 1,
      order: 1,
      content: @valid_content
    }

    test "changeset with valid content structure" do
      changeset = Lesson.changeset(%Lesson{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with missing version" do
      invalid_content = Map.delete(@valid_content, "version")
      attrs = %{@valid_attrs | content: invalid_content}
      changeset = Lesson.changeset(%Lesson{}, attrs)
      refute changeset.valid?
      assert "must include a version field" in errors_on(changeset).content
    end

    test "changeset with missing sections" do
      invalid_content = Map.delete(@valid_content, "sections")
      attrs = %{@valid_attrs | content: invalid_content}
      changeset = Lesson.changeset(%Lesson{}, attrs)
      refute changeset.valid?

      assert "must include a sections field with a list of sections" in errors_on(changeset).content
    end

    test "changeset with unknown section type is valid" do
      content_with_unknown_type = %{
        @valid_content
        | "sections" => [
            %{
              "type" => "unknown_type",
              "content" => "Some content"
            }
          ]
      }

      attrs = %{@valid_attrs | content: content_with_unknown_type}
      changeset = Lesson.changeset(%Lesson{}, attrs)
      assert changeset.valid?
    end

    test "changeset with missing required section fields" do
      invalid_content = %{
        @valid_content
        | "sections" => [
            %{
              "type" => "text"
              # missing content field for known type
            }
          ]
      }

      attrs = %{@valid_attrs | content: invalid_content}
      changeset = Lesson.changeset(%Lesson{}, attrs)
      refute changeset.valid?

      assert Enum.any?(
               errors_on(changeset).content,
               &String.contains?(&1, "invalid section structure")
             )
    end
  end

  describe "content helper functions" do
    @lesson_with_content %Lesson{
      content: %{
        "version" => "1.2",
        "sections" => [
          %{"type" => "text", "content" => "Hello"},
          %{"type" => "code_snippet", "language" => "elixir", "content" => "IO.puts(\"test\")"}
        ],
        "objectives" => ["Learn basics", "Practice coding"],
        "prerequisites" => ["intro-programming"],
        "estimated_time" => 30
      }
    }

    test "get_content_version/1 returns version" do
      assert Lesson.get_content_version(@lesson_with_content) == "1.2"
    end

    test "get_content_version/1 returns default for missing version" do
      lesson = %Lesson{content: %{}}
      assert Lesson.get_content_version(lesson) == "1.0"
    end

    test "get_sections/1 returns sections list" do
      sections = Lesson.get_sections(@lesson_with_content)
      assert length(sections) == 2
      assert Enum.at(sections, 0)["type"] == "text"
      assert Enum.at(sections, 1)["type"] == "code_snippet"
    end

    test "get_sections/1 returns empty list for missing sections" do
      lesson = %Lesson{content: %{}}
      assert Lesson.get_sections(lesson) == []
    end

    test "get_objectives/1 returns objectives list" do
      objectives = Lesson.get_objectives(@lesson_with_content)
      assert objectives == ["Learn basics", "Practice coding"]
    end

    test "get_objectives/1 returns empty list for missing objectives" do
      lesson = %Lesson{content: %{}}
      assert Lesson.get_objectives(lesson) == []
    end

    test "get_prerequisites/1 returns prerequisites list" do
      prerequisites = Lesson.get_prerequisites(@lesson_with_content)
      assert prerequisites == ["intro-programming"]
    end

    test "get_prerequisites/1 returns empty list for missing prerequisites" do
      lesson = %Lesson{content: %{}}
      assert Lesson.get_prerequisites(lesson) == []
    end

    test "get_estimated_time/1 returns time" do
      assert Lesson.get_estimated_time(@lesson_with_content) == 30
    end

    test "get_estimated_time/1 returns nil for missing time" do
      lesson = %Lesson{content: %{}}
      assert Lesson.get_estimated_time(lesson) == nil
    end
  end

  describe "content building functions" do
    test "build_content/2 creates valid content structure" do
      sections = [
        %{"type" => "text", "content" => "Hello"},
        %{"type" => "code_snippet", "language" => "elixir", "content" => "IO.puts(\"test\")"}
      ]

      opts = [
        version: "2.0",
        objectives: ["Learn", "Practice"],
        prerequisites: ["basics"],
        estimated_time: 25
      ]

      content = Lesson.build_content(sections, opts)

      assert content["version"] == "2.0"
      assert content["sections"] == sections
      assert content["objectives"] == ["Learn", "Practice"]
      assert content["prerequisites"] == ["basics"]
      assert content["estimated_time"] == 25
    end

    test "build_content/2 with minimal options" do
      sections = [%{"type" => "text", "content" => "Hello"}]
      content = Lesson.build_content(sections)

      assert content["version"] == "1.0"
      assert content["sections"] == sections
      refute Map.has_key?(content, "objectives")
      refute Map.has_key?(content, "prerequisites")
      refute Map.has_key?(content, "estimated_time")
    end

    test "text_section/2 creates text section" do
      section = Lesson.text_section("Hello World")
      assert section == %{"type" => "text", "content" => "Hello World"}
    end

    test "text_section/2 with title" do
      section = Lesson.text_section("Hello World", title: "Introduction")
      assert section == %{"type" => "text", "content" => "Hello World", "title" => "Introduction"}
    end

    test "code_snippet_section/3 creates code snippet section" do
      section = Lesson.code_snippet_section("IO.puts(\"hello\")")

      expected = %{
        "type" => "code_snippet",
        "language" => "elixir",
        "content" => "IO.puts(\"hello\")"
      }

      assert section == expected
    end

    test "code_snippet_section/3 with custom language and title" do
      section =
        Lesson.code_snippet_section("console.log('hello')", "javascript", title: "JS Example")

      expected = %{
        "type" => "code_snippet",
        "language" => "javascript",
        "content" => "console.log('hello')",
        "title" => "JS Example"
      }

      assert section == expected
    end

    test "task_section/3 creates task section" do
      section = Lesson.task_section("Practice", "Write a function")

      expected = %{
        "type" => "task",
        "title" => "Practice",
        "description" => "Write a function"
      }

      assert section == expected
    end

    test "task_section/3 with hints" do
      section =
        Lesson.task_section("Practice", "Write a function",
          hints: ["Use pattern matching", "Remember the return value"]
        )

      expected = %{
        "type" => "task",
        "title" => "Practice",
        "description" => "Write a function",
        "hints" => ["Use pattern matching", "Remember the return value"]
      }

      assert section == expected
    end
  end
end
