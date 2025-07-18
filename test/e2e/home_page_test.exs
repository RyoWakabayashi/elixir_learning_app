defmodule ElixirLearningAppWeb.HomePageTest do
  use PhoenixTest.Playwright.Case, async: true
  use ElixirLearningAppWeb, :verified_routes

  test "home page loads correctly", %{conn: conn} do
    conn
    # ルートパスにアクセスすると、デフォルト言語（英語）にリダイレクトされる
    |> visit("/")
    # 英語のホームページに直接アクセス
    |> visit("/en")
    # Verify main heading
    |> assert_has("h1", text: "Interactive Elixir Lessons")
    # Verify page structure
    |> assert_has("nav")
    |> assert_has("main")
    |> assert_has("footer")
    # Take screenshot for visual verification
    |> screenshot("home_page.png")
  end

  test "home page content is displayed correctly", %{conn: conn} do
    conn
    |> visit("/en")
    # Verify welcome message
    |> assert_has("main p",
      text: "Learn Elixir programming through interactive, hands-on lessons"
    )
  end

  test "navigation between pages works", %{conn: conn} do
    conn
    |> visit("/en")
    # Verify navigation links exist
    |> assert_has("nav a", text: "Home")
    |> assert_has("nav a", text: "Lessons")
    |> assert_has("nav a", text: "About")

    # Click on the lessons link and verify navigation
    |> click_link("nav a", "Lessons")
    |> assert_path("/en/lessons")

    # Navigate to about page
    |> click_link("nav a", "About")
    |> assert_path("/en/about")

    # Return to home page
    |> click_link("nav a", "Home")
    |> assert_path("/en")
  end

  test "language content is displayed correctly", %{conn: conn} do
    # 英語のホームページを確認
    conn
    |> visit("/en")
    |> assert_has("h1", text: "Interactive Elixir Lessons")
    |> assert_has("main p",
      text: "Learn Elixir programming through interactive, hands-on lessons"
    )

    # 日本語のホームページを確認
    conn
    |> visit("/ja")
    |> assert_has("h1", text: "インタラクティブ Elixir レッスン")
    |> assert_has("main p", text: "インタラクティブな実践レッスンを通じてElixirプログラミングを学ぶ")
  end
end
