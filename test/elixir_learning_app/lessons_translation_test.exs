defmodule ElixirLearningApp.LessonsTranslationTest do
  use ElixirLearningApp.DataCase

  alias ElixirLearningApp.Lessons
  alias ElixirLearningApp.Lessons.Lesson

  describe "lesson translations" do
    setup do
      # Create a test lesson
      {:ok, lesson} =
        Lessons.create_lesson_with_content(
          "Variables and Types",
          "variables-and-types",
          "basics",
          1,
          1,
          [
            Lesson.text_section("Learn about Elixir variables", title: "Introduction"),
            Lesson.code_snippet_section("name = \"Alice\"", "elixir", title: "Example"),
            Lesson.task_section("Practice", "Create your own variables",
              hints: ["Use descriptive names"]
            )
          ],
          description: "Learn the basics of Elixir variables",
          objectives: ["Understand variables", "Practice assignment"],
          estimated_time: 15
        )

      %{lesson: lesson}
    end

    test "create_lesson_translation/3 creates a new translation", %{lesson: lesson} do
      translation_data = %{
        "title" => "変数と型",
        "description" => "Elixirの変数の基本を学びましょう",
        "content" => %{
          "objectives" => ["変数を理解する", "代入を練習する"],
          "sections" => [
            %{"title" => "はじめに", "content" => "Elixirの変数について学びます"},
            %{"title" => "例"},
            %{"title" => "練習", "description" => "自分で変数を作ってみましょう", "hints" => ["わかりやすい名前を使いましょう"]}
          ]
        }
      }

      assert {:ok, translation} =
               Lessons.create_lesson_translation(lesson.slug, "ja", translation_data)

      assert translation.locale == "ja"
      assert translation.key == "lesson.#{lesson.slug}"
      assert translation.content["title"] == "変数と型"
    end

    test "get_lesson_with_translations/2 returns lesson with Japanese translations", %{
      lesson: lesson
    } do
      # Create Japanese translation
      translation_data = %{
        "title" => "変数と型",
        "description" => "Elixirの変数の基本を学びましょう",
        "content" => %{
          "objectives" => ["変数を理解する", "代入を練習する"],
          "sections" => [
            %{"title" => "はじめに", "content" => "Elixirの変数について学びます"},
            %{"title" => "例"},
            %{"title" => "練習", "description" => "自分で変数を作ってみましょう"}
          ]
        }
      }

      {:ok, _translation} = Lessons.create_lesson_translation(lesson.slug, "ja", translation_data)

      # Get lesson with Japanese translations
      translated_lesson = Lessons.get_lesson_with_translations(lesson.slug, "ja")

      assert translated_lesson.title == "変数と型"
      assert translated_lesson.description == "Elixirの変数の基本を学びましょう"

      objectives = Lesson.get_objectives(translated_lesson)
      assert objectives == ["変数を理解する", "代入を練習する"]

      sections = Lesson.get_sections(translated_lesson)
      assert length(sections) == 3

      # Text section should be translated
      text_section = Enum.at(sections, 0)
      assert text_section["title"] == "はじめに"
      assert text_section["content"] == "Elixirの変数について学びます"

      # Code section should have translated title but original code
      code_section = Enum.at(sections, 1)
      assert code_section["title"] == "例"
      # Original code preserved
      assert code_section["content"] == "name = \"Alice\""

      # Task section should be translated
      task_section = Enum.at(sections, 2)
      assert task_section["title"] == "練習"
      assert task_section["description"] == "自分で変数を作ってみましょう"
    end

    test "get_lesson_with_translations/2 falls back to English when translation missing", %{
      lesson: lesson
    } do
      # Get lesson with non-existent translation
      translated_lesson = Lessons.get_lesson_with_translations(lesson.slug, "ja")

      # Should return original English content
      assert translated_lesson.title == lesson.title
      assert translated_lesson.description == lesson.description
      assert Lesson.get_objectives(translated_lesson) == Lesson.get_objectives(lesson)
    end

    test "get_lesson_with_translations/2 preserves code examples in translations", %{
      lesson: lesson
    } do
      translation_data = %{
        "content" => %{
          "sections" => [
            %{"title" => "はじめに", "content" => "Elixirの変数について学びます"},
            # This should be ignored
            %{"title" => "例", "content" => "変更されたコード"},
            %{"title" => "練習"}
          ]
        }
      }

      {:ok, _translation} = Lessons.create_lesson_translation(lesson.slug, "ja", translation_data)
      translated_lesson = Lessons.get_lesson_with_translations(lesson.slug, "ja")

      sections = Lesson.get_sections(translated_lesson)
      code_section = Enum.at(sections, 1)

      # Code content should remain original, only title translated
      assert code_section["title"] == "例"
      # Original code preserved
      assert code_section["content"] == "name = \"Alice\""
    end

    test "update_lesson_translation/3 updates existing translation", %{lesson: lesson} do
      # Create initial translation
      initial_data = %{"title" => "変数と型"}
      {:ok, _translation} = Lessons.create_lesson_translation(lesson.slug, "ja", initial_data)

      # Update translation
      update_data = %{"title" => "変数と型（更新版）", "description" => "更新された説明"}

      assert {:ok, updated_translation} =
               Lessons.update_lesson_translation(lesson.slug, "ja", update_data)

      assert updated_translation.content["title"] == "変数と型（更新版）"
      assert updated_translation.content["description"] == "更新された説明"
    end

    test "update_lesson_translation/3 creates translation if it doesn't exist", %{lesson: lesson} do
      translation_data = %{"title" => "新しい翻訳"}

      assert {:ok, translation} =
               Lessons.update_lesson_translation(lesson.slug, "ja", translation_data)

      assert translation.content["title"] == "新しい翻訳"
    end

    test "get_lesson_translations/1 returns all translations for a lesson", %{lesson: lesson} do
      # Create Japanese translation
      ja_data = %{"title" => "変数と型"}
      {:ok, _ja_translation} = Lessons.create_lesson_translation(lesson.slug, "ja", ja_data)

      translations = Lessons.get_lesson_translations(lesson.slug)

      assert Map.has_key?(translations, "en")
      assert Map.has_key?(translations, "ja")
      assert translations["ja"]["title"] == "変数と型"
      # No English translation created
      assert translations["en"] == %{}
    end

    test "translation preserves lesson structure and metadata", %{lesson: lesson} do
      translation_data = %{
        "title" => "変数と型",
        "content" => %{
          "objectives" => ["変数を理解する"]
        }
      }

      {:ok, _translation} = Lessons.create_lesson_translation(lesson.slug, "ja", translation_data)
      translated_lesson = Lessons.get_lesson_with_translations(lesson.slug, "ja")

      # Basic lesson properties should be preserved
      assert translated_lesson.id == lesson.id
      assert translated_lesson.slug == lesson.slug
      assert translated_lesson.category == lesson.category
      assert translated_lesson.difficulty == lesson.difficulty
      assert translated_lesson.order == lesson.order

      # Content structure should be preserved
      assert Lesson.get_content_version(translated_lesson) == Lesson.get_content_version(lesson)
      assert Lesson.get_estimated_time(translated_lesson) == Lesson.get_estimated_time(lesson)
    end

    test "translation handles missing sections gracefully", %{lesson: lesson} do
      # Translation with fewer sections than original
      translation_data = %{
        "content" => %{
          "sections" => [
            %{"title" => "はじめに", "content" => "翻訳されたテキスト"}
          ]
        }
      }

      {:ok, _translation} = Lessons.create_lesson_translation(lesson.slug, "ja", translation_data)
      translated_lesson = Lessons.get_lesson_with_translations(lesson.slug, "ja")

      sections = Lesson.get_sections(translated_lesson)
      # Original number of sections preserved
      assert length(sections) == 3

      # First section should be translated
      assert Enum.at(sections, 0)["title"] == "はじめに"
      assert Enum.at(sections, 0)["content"] == "翻訳されたテキスト"

      # Other sections should remain original
      assert Enum.at(sections, 1)["title"] == "Example"
      assert Enum.at(sections, 2)["title"] == "Practice"
    end

    test "translation handles unknown section types", %{lesson: _lesson} do
      # Add a lesson with unknown section type
      {:ok, lesson_with_unknown} =
        Lessons.create_lesson_with_content(
          "Test Lesson",
          "test-unknown-section",
          "basics",
          1,
          2,
          [
            %{"type" => "unknown_type", "content" => "Some content", "custom_field" => "value"}
          ]
        )

      translation_data = %{
        "content" => %{
          "sections" => [
            %{"content" => "翻訳されたコンテンツ", "custom_field" => "翻訳された値"}
          ]
        }
      }

      {:ok, _translation} =
        Lessons.create_lesson_translation(lesson_with_unknown.slug, "ja", translation_data)

      translated_lesson = Lessons.get_lesson_with_translations(lesson_with_unknown.slug, "ja")

      sections = Lesson.get_sections(translated_lesson)
      section = Enum.at(sections, 0)

      # Unknown section types should merge all fields
      assert section["content"] == "翻訳されたコンテンツ"
      assert section["custom_field"] == "翻訳された値"
      # Original type preserved
      assert section["type"] == "unknown_type"
    end
  end
end
