defmodule ElixirLearningAppWeb.LessonsLiveTest do
  use ElixirLearningAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import ElixirLearningApp.LessonsFixtures

  describe "Lessons Live" do
    test "displays lessons grouped by category", %{conn: conn} do
      # Create test lessons
      lesson1 =
        lesson_fixture(%{
          title: "Test Lesson 1",
          slug: "test-lesson-1",
          category: "basics",
          difficulty: 1,
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          title: "Test Lesson 2",
          slug: "test-lesson-2",
          category: "advanced",
          difficulty: 3,
          order: 1
        })

      {:ok, _view, html} = live(conn, ~p"/en/lessons")

      assert html =~ "Elixir Lessons"
      assert html =~ lesson1.title
      assert html =~ lesson2.title
      assert html =~ "Beginner"
      assert html =~ "Intermediate"
    end

    test "filters lessons by category", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          title: "Basic Lesson",
          slug: "basic-lesson",
          category: "basics",
          difficulty: 1,
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          title: "Advanced Lesson",
          slug: "advanced-lesson",
          category: "advanced",
          difficulty: 3,
          order: 1
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons")

      # Filter by basics category
      html =
        view
        |> form("form", %{category: "basics", difficulty: "", search: ""})
        |> render_change()

      assert html =~ lesson1.title
      refute html =~ lesson2.title
    end

    test "filters lessons by difficulty", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          title: "Easy Lesson",
          slug: "easy-lesson",
          category: "basics",
          difficulty: 1,
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          title: "Hard Lesson",
          slug: "hard-lesson",
          category: "basics",
          difficulty: 4,
          order: 2
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons")

      # Filter by difficulty 1
      html =
        view
        |> form("form", %{category: "", difficulty: "1", search: ""})
        |> render_change()

      assert html =~ lesson1.title
      refute html =~ lesson2.title
    end

    test "searches lessons by title", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          title: "Variables and Types",
          slug: "variables-types",
          category: "basics",
          difficulty: 1,
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          title: "Functions and Modules",
          slug: "functions-modules",
          category: "basics",
          difficulty: 2,
          order: 2
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons")

      # Search for "variables"
      html =
        view
        |> form("form", %{category: "", difficulty: "", search: "variables"})
        |> render_change()

      assert html =~ lesson1.title
      refute html =~ lesson2.title
    end

    test "clears filters", %{conn: conn} do
      lesson1 =
        lesson_fixture(%{
          title: "Basic Lesson",
          slug: "basic-lesson",
          category: "basics",
          difficulty: 1,
          order: 1
        })

      lesson2 =
        lesson_fixture(%{
          title: "Advanced Lesson",
          slug: "advanced-lesson",
          category: "advanced",
          difficulty: 3,
          order: 1
        })

      {:ok, view, _html} = live(conn, ~p"/en/lessons")

      # Apply filter
      view
      |> form("form", %{category: "basics", difficulty: "", search: ""})
      |> render_change()

      # Clear filters
      html =
        view
        |> element("button", "Clear Filters")
        |> render_click()

      assert html =~ lesson1.title
      assert html =~ lesson2.title
    end

    test "shows empty state when no lessons match filters", %{conn: conn} do
      lesson_fixture(%{
        title: "Basic Lesson",
        slug: "basic-lesson",
        category: "basics",
        difficulty: 1,
        order: 1
      })

      {:ok, view, _html} = live(conn, ~p"/en/lessons")

      # Search for something that doesn't exist
      html =
        view
        |> form("form", %{category: "", difficulty: "", search: "nonexistent"})
        |> render_change()

      assert html =~ "No lessons found"
      assert html =~ "Try adjusting your filters"
    end

    test "displays progress summary", %{conn: conn} do
      lesson_fixture(%{
        title: "Test Lesson",
        slug: "test-lesson",
        category: "basics",
        difficulty: 1,
        order: 1
      })

      {:ok, _view, html} = live(conn, ~p"/en/lessons")

      assert html =~ "Your Progress"
      assert html =~ "Completed"
      assert html =~ "of"
      assert html =~ "lessons"
    end

    test "shows estimated time for lessons", %{conn: conn} do
      lesson_fixture(%{
        title: "Timed Lesson",
        slug: "timed-lesson",
        category: "basics",
        difficulty: 1,
        order: 1,
        content: %{
          "version" => "1.0",
          "sections" => [
            %{"type" => "text", "content" => "Test content"}
          ],
          "estimated_time" => 25
        }
      })

      {:ok, _view, html} = live(conn, ~p"/en/lessons")

      assert html =~ "25 min"
    end
  end
end
