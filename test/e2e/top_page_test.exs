defmodule ElixirLearningAppWeb.TopPageTest do
  use PhoenixTest.Playwright.Case, async: true
  use ElixirLearningAppWeb, :verified_routes

  test "register", %{conn: conn} do
    conn
    |> visit("/")
    |> screenshot("top.png")
  end
end
