defmodule ElixirLearningAppWeb.AboutPageTest do
  use PhoenixTest.Playwright.Case, async: true
  use ElixirLearningAppWeb, :verified_routes

  test "about page content is displayed", %{conn: conn} do
    conn
    |> visit("/en/about")
    # Verify about page content
    |> assert_has("h1", text: "About Interactive Elixir Lessons")
    # Verify page structure
    |> assert_has("nav")
    |> assert_has("main")
    |> assert_has("footer")
    # Take screenshot for visual verification
    |> screenshot("about_page.png")
  end

  test "about page sections are displayed correctly", %{conn: conn} do
    conn
    |> visit("/en/about")
    # Verify mission statement section
    |> assert_has("h2", text: "Our Mission")
    # Verify features section
    |> assert_has("h2", text: "Features")
    # Verify technology section
    |> assert_has("h2", text: "Technology")
  end

  test "navigation from about page works", %{conn: conn} do
    conn
    |> visit("/en/about")
    # Verify navigation links exist
    |> assert_has("nav a", text: "Home")
    |> assert_has("nav a", text: "Lessons")
    |> assert_has("nav a", text: "About")

    # Navigate to home page
    |> click_link("nav a", "Home")
    |> assert_path("/en")

    # Navigate back to about page
    |> visit("/en/about")
    # Navigate to lessons page
    |> click_link("nav a", "Lessons")
    |> assert_path("/en/lessons")
  end

  test "language content is displayed correctly on about page", %{conn: conn} do
    # 英語の概要ページを確認
    conn
    |> visit("/en/about")
    |> assert_has("h1", text: "About Interactive Elixir Lessons")
    |> assert_has("h2", text: "Our Mission")

    # 日本語の概要ページを確認
    conn
    |> visit("/ja/about")
    |> assert_has("h1", text: "インタラクティブ Elixir レッスンについて")
    |> assert_has("h2", text: "私たちの使命")
  end
end
