defmodule ElixirLearningAppWeb.PageControllerTest do
  use ElixirLearningAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/en/")
    assert html_response(conn, 200) =~ "Interactive Elixir Lessons"
  end
end
