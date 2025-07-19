defmodule ElixirLearningAppWeb.Components.CodeOutputTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest
  alias ElixirLearningAppWeb.Components.CodeOutput

  test "renders empty output state" do
    html = render_component(&CodeOutput.code_output/1, id: "test-output")

    assert html =~ "id=\"test-output\""
    assert html =~ "class=\"code-output-container"
    assert html =~ "Execute code to see output"
  end

  test "renders successful output" do
    html =
      render_component(&CodeOutput.code_output/1,
        id: "test-output",
        output: "Hello, World!"
      )

    assert html =~ "id=\"test-output\""
    assert html =~ "class=\"code-output-result\""
    assert html =~ "Hello, World!"
  end

  test "renders error output" do
    error_message = "** (RuntimeError) error on line 5"

    html =
      render_component(&CodeOutput.code_output/1,
        id: "test-output",
        error: error_message
      )

    assert html =~ "id=\"test-output\""
    assert html =~ "class=\"code-output-error\""
    assert html =~ "code-output-line-number"
    assert html =~ "line 5"
  end

  test "renders loading state" do
    html =
      render_component(&CodeOutput.code_output/1,
        id: "test-output",
        loading: true
      )

    assert html =~ "id=\"test-output\""
    assert html =~ "class=\"code-output-loading\""
    assert html =~ "code-output-loading-spinner"
    assert html =~ "Executing code..."
  end

  test "applies custom class" do
    html =
      render_component(&CodeOutput.code_output/1,
        id: "test-output",
        class: "custom-class"
      )

    assert html =~ "class=\"code-output-container custom-class\""
  end
end
