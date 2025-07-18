defmodule ElixirLearningAppWeb.LessonsPageTest do
  use PhoenixTest.Playwright.Case, async: true
  use ElixirLearningAppWeb, :verified_routes

  test "lessons page loads correctly", %{conn: conn} do
    conn
    |> visit("/en/lessons")
    # Verify main heading
    |> assert_has("h1", text: "Elixir Lessons")
    # Verify page structure
    |> assert_has("nav")
    |> assert_has("main")
    |> assert_has("footer")
    # Take screenshot for visual verification
    |> screenshot("lessons_page.png")
  end

  test "lesson categories are displayed", %{conn: conn} do
    conn
    |> visit("/en/lessons")
    # Verify lesson categories are displayed
    |> assert_has("h2", text: "Elixir Basics")
    |> assert_has("h2", text: "Pattern Matching")
    |> assert_has("h2", text: "Processes & OTP")
    |> assert_has("h2", text: "Phoenix LiveView")
  end

  test "lesson cards display correctly", %{conn: conn} do
    conn
    |> visit("/en/lessons")
    # 基本カテゴリのレッスンカードを確認
    |> assert_has("h3", text: "Variables & Types")
    |> assert_has("h3", text: "Functions")
    |> assert_has("h3", text: "Modules")

    # 難易度ラベルが表示されていることを確認
    |> assert_has("span", text: "Beginner")
    |> assert_has("span", text: "Easy")
    |> assert_has("span", text: "Intermediate")
  end

  test "lesson navigation works", %{conn: conn} do
    conn
    |> visit("/en/lessons")
    # レッスンの「Start Lesson」リンクが存在することを確認
    |> assert_has("a", text: "Start Lesson")
  end

  test "lesson filtering works", %{conn: conn} do
    conn
    |> visit("/en/lessons")
    # 各カテゴリに対応するレッスンが表示されていることを確認

    # Elixir Basicsカテゴリには「Variables & Types」が含まれる
    |> assert_has("h2", text: "Elixir Basics")
    |> assert_has("h3", text: "Variables & Types")

    # Pattern Matchingカテゴリには「Basic Pattern Matching」が含まれる
    |> assert_has("h2", text: "Pattern Matching")
    |> assert_has("h3", text: "Basic Pattern Matching")

    # Processes & OTPカテゴリには「Introduction to Processes」が含まれる
    |> assert_has("h2", text: "Processes & OTP")
    |> assert_has("h3", text: "Introduction to Processes")

    # Phoenix LiveViewカテゴリには「LiveView Basics」が含まれる
    |> assert_has("h2", text: "Phoenix LiveView")
    |> assert_has("h3", text: "LiveView Basics")
  end

  test "language content is displayed correctly on lessons page", %{conn: conn} do
    # 英語のレッスンページを確認
    conn
    |> visit("/en/lessons")
    |> assert_has("h1", text: "Elixir Lessons")
    |> assert_has("p", text: "Choose a lesson category to start learning Elixir")

    # 日本語のレッスンページを確認
    conn
    |> visit("/ja/lessons")
    |> assert_has("h1", text: "Elixir レッスン")
    |> assert_has("p", text: "Elixirの学習を始めるためのレッスンカテゴリを選択してください")
  end
end
