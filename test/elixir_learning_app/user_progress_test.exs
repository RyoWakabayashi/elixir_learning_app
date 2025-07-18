defmodule ElixirLearningApp.UserProgressTest do
  use ElixirLearningApp.DataCase

  alias ElixirLearningApp.Lessons
  alias ElixirLearningApp.Users.UserProgressManager

  describe "user_progress" do
    @user_id "user123"

    @lesson_attrs %{
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
      }
    }

    def lesson_fixture do
      {:ok, lesson} = Lessons.create_lesson(@lesson_attrs)
      lesson
    end

    def user_progress_fixture(lesson_id) do
      {:ok, user_progress} =
        UserProgressManager.upsert_user_progress(%{
          user_id: @user_id,
          lesson_id: lesson_id
        })

      user_progress
    end

    test "get_user_progress/2 returns user progress for a specific lesson" do
      lesson = lesson_fixture()
      user_progress = user_progress_fixture(lesson.id)

      assert UserProgressManager.get_user_progress(@user_id, lesson.id).id == user_progress.id
    end

    test "complete_lesson/3 marks a lesson as completed" do
      lesson = lesson_fixture()
      last_code = "IO.puts(\"Hello, world!\")"

      assert {:ok, user_progress} =
               UserProgressManager.complete_lesson(@user_id, lesson.id, last_code)

      assert user_progress.completed == true
      assert user_progress.last_code == last_code
      assert not is_nil(user_progress.completed_at)
    end

    test "record_attempt/3 increments the attempt count" do
      lesson = lesson_fixture()
      last_code = "IO.puts(\"Hello, world!\")"

      # First attempt
      assert {:ok, user_progress1} =
               UserProgressManager.record_attempt(@user_id, lesson.id, last_code)

      assert user_progress1.attempts == 1
      assert user_progress1.last_code == last_code

      # Second attempt
      assert {:ok, user_progress2} =
               UserProgressManager.record_attempt(@user_id, lesson.id, "updated code")

      assert user_progress2.attempts == 2
      assert user_progress2.last_code == "updated code"
    end

    test "get_progress_summary/1 returns the user's progress summary" do
      # Create two lessons
      lesson1 = lesson_fixture()

      {:ok, _lesson2} =
        Lessons.create_lesson(%{
          title: "Pattern Matching",
          slug: "pattern-matching",
          description: "Learn about pattern matching in Elixir",
          category: "basics",
          difficulty: 1,
          order: 2,
          content: %{}
        })

      # Complete one lesson
      UserProgressManager.complete_lesson(@user_id, lesson1.id)

      # Get progress summary
      summary = UserProgressManager.get_progress_summary(@user_id)

      assert summary.completed == 1
      assert summary.total == 2
      assert summary.categories["basics"].completed == 1
      assert summary.categories["basics"].total == 2
    end
  end
end
