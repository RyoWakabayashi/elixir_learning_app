defmodule ElixirLearningAppWeb.LessonLiveTest do
  use ElixirLearningAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import ElixirLearningApp.LessonsFixtures

  describe "Lesson Live" do
    test "displays lesson content and code editor", %{conn: conn} do
      lesson =
        lesson_fixture(%{
          title: "Test Lesson",
          slug: "test-lesson",
          description: "A test lesson for learning",
          content: %{
            "version" => "1.0",
            "sections" => [
              %{
                "type" => "text",
                "content" => "Welcome to this lesson!"
              },
              %{
                "type" => "code_snippet",
                "language" => "elixir",
                "content" => "IO.puts(\"Hello, World!\")",
                "title" => "Example Code"
              },
              %{
                "type" => "task",
                "title" => "Your Turn",
                "description" => "Write your own code",
                "hints" => ["Remember to use IO.puts", "Don't forget the quotes"]
              }
            ],
            "objectives" => ["Learn basic syntax", "Practice coding"],
            "estimated_time" => 20
          },
          initial_code: "# Write your code here"
        })

      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      # Check lesson header
      assert html =~ lesson.title
      assert html =~ lesson.description
      assert html =~ "20 min"

      # Check lesson content sections
      assert html =~ "Welcome to this lesson!"
      assert html =~ "Example Code"
      assert html =~ "IO.puts(&quot;Hello, World!&quot;)"
      assert html =~ "Your Turn"
      assert html =~ "Write your own code"

      # Check objectives
      assert html =~ "Learning Objectives"
      assert html =~ "Learn basic syntax"
      assert html =~ "Practice coding"

      # Check code editor
      assert html =~ "Code Editor"
      assert html =~ "# Write your code here"
      assert html =~ "Run Code"
      assert html =~ "Reset"
    end

    test "redirects for non-existent lesson", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/en/lessons", flash: %{"error" => "Lesson not found"}}}} =
               live(conn, ~p"/en/lessons/non-existent-lesson")
    end

    test "toggles instructions panel", %{conn: conn} do
      lesson = lesson_fixture(%{slug: "toggle-test"})

      {:ok, view, html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      # Instructions should be visible initially
      assert html =~ "Learning Objectives"

      # Toggle instructions off
      html =
        view
        |> element("button[title='Hide Instructions']")
        |> render_click()

      # Instructions should be hidden, code editor should take full width
      refute html =~ "Learning Objectives"
      assert html =~ "width: 100%"

      # Toggle instructions back on
      html =
        view
        |> element("button[title='Show Instructions']")
        |> render_click()

      # Instructions should be visible again
      assert html =~ "Learning Objectives"
    end

    test "resets code to initial state", %{conn: conn} do
      lesson =
        lesson_fixture(%{
          slug: "reset-test",
          initial_code: "# Initial code"
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      # Change the code
      view
      |> element("textarea[name='code']")
      |> render_change(%{code: "# Modified code"})

      # Reset the code
      html =
        view
        |> element("button", "Reset")
        |> render_click()

      # Code should be back to initial state
      assert html =~ "# Initial code"
    end

    test "handles code execution", %{conn: conn} do
      lesson =
        lesson_fixture(%{
          slug: "execution-test",
          initial_code: "IO.puts(\"Hello, World!\")"
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      # Run the code
      html =
        view
        |> element("button", "Run Code")
        |> render_click()

      # Should show executing state
      assert html =~ "Running..."
      assert html =~ "Executing..."
    end

    test "displays navigation to next and previous lessons", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          slug: "lesson-1",
          category: "basics",
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          slug: "lesson-2",
          category: "basics",
          order: 2
        })

      lesson3 =
        lesson_fixture(%{
          slug: "lesson-3",
          category: "basics",
          order: 3
        })

      # Test middle lesson (should have both prev and next)
      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson2.slug}")

      assert html =~ "Previous"
      assert html =~ "Next"

      # Test first lesson (should only have next)
      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson1.slug}")

      refute html =~ "Previous"
      assert html =~ "Next"

      # Test last lesson (should only have previous)
      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson3.slug}")

      assert html =~ "Previous"
      refute html =~ "Next"
    end

    test "navigates between lessons", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          slug: "nav-lesson-1",
          category: "basics",
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          slug: "nav-lesson-2",
          category: "basics",
          order: 2
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons/#{lesson1.slug}")

      # Navigate to next lesson
      view
      |> element("button", "Next →")
      |> render_click()

      # Should redirect to lesson2
      assert_redirect(view, ~p"/en/lessons/#{lesson2.slug}")
    end

    test "displays progress information", %{conn: conn} do
      lesson = lesson_fixture(%{slug: "progress-test"})

      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      assert html =~ "Progress"
      assert html =~ "In Progress"
      assert html =~ "Attempts:"
    end

    test "shows hints in task sections", %{conn: conn} do
      lesson =
        lesson_fixture(%{
          slug: "hints-test",
          content: %{
            "version" => "1.0",
            "sections" => [
              %{
                "type" => "task",
                "title" => "Practice Task",
                "description" => "Complete this task",
                "hints" => ["Hint 1", "Hint 2"]
              }
            ]
          }
        })

      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      assert html =~ "Practice Task"
      assert html =~ "Complete this task"
      assert html =~ "Hints"
      # Hints should be in a collapsible details element
      assert html =~ "<details"
    end

    test "handles different content section types", %{conn: conn} do
      lesson =
        lesson_fixture(%{
          slug: "content-types-test",
          content: %{
            "version" => "1.0",
            "sections" => [
              %{
                "type" => "text",
                "title" => "Text Section",
                "content" => "This is text content"
              },
              %{
                "type" => "code_snippet",
                "title" => "Code Example",
                "language" => "elixir",
                "content" => "def hello, do: \"world\""
              },
              %{
                "type" => "unknown_type",
                "content" => "This should show unknown type message"
              }
            ]
          }
        })

      {:ok, _view, html} = live(conn, ~p"/en/lessons/#{lesson.slug}")

      # Text section
      assert html =~ "Text Section"
      assert html =~ "This is text content"

      # Code snippet section
      assert html =~ "Code Example"
      assert html =~ "def hello, do: &quot;world&quot;"

      # Unknown section type
      assert html =~ "Unknown content type"
    end
  end
end
