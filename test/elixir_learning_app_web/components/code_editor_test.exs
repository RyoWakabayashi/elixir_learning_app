defmodule ElixirLearningAppWeb.Components.CodeEditorTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest
  alias ElixirLearningAppWeb.Components.CodeEditor

  test "renders code editor with default values" do
    html = render_component(&CodeEditor.code_editor/1, id: "test-editor")

    assert html =~ "id=\"test-editor\""
    assert html =~ "phx-hook=\"CodeEditor\""
    assert html =~ "data-language=\"elixir\""
    assert html =~ "data-theme=\"vs-dark\""
    assert html =~ "data-readonly=\"false\""
  end

  test "renders code editor with custom values" do
    html =
      render_component(&CodeEditor.code_editor/1,
        id: "custom-editor",
        value: "IO.puts(\"Hello, World!\")",
        language: "javascript",
        theme: "vs-light",
        readonly: true,
        class: "custom-class"
      )

    assert html =~ "id=\"custom-editor\""
    assert html =~ "class=\"code-editor-container custom-class\""
    assert html =~ "data-language=\"javascript\""
    assert html =~ "data-theme=\"vs-light\""
    assert html =~ "data-readonly=\"true\""
    assert html =~ "data-value=\"IO.puts(&quot;Hello, World!&quot;)\""
  end

  test "renders code editor with form field" do
    # Create a form manually without using Phoenix.HTML.Form.form_for
    form = %Phoenix.HTML.Form{
      source: %{},
      impl: Phoenix.HTML.FormData.Plug.Conn,
      id: nil,
      name: "form",
      params: %{},
      data: %{},
      hidden: [],
      options: []
    }

    html =
      render_component(&CodeEditor.code_editor/1,
        id: "form-editor",
        form: form,
        field: :code
      )

    assert html =~ "id=\"form-editor\""
    assert html =~ "id=\"form-editor-input\""
    assert html =~ "name=\"form[code]\""

    html
  end
end
