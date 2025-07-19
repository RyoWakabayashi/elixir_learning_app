defmodule ElixirLearningAppWeb.Components.CodeEditor do
  @moduledoc """
  Component for rendering a code editor using Monaco Editor.
  Provides integration with Phoenix forms and LiveView.
  """
  use Phoenix.Component
  alias Phoenix.HTML.Form

  attr :id, :string, required: true
  attr :value, :string, default: ""
  attr :language, :string, default: "elixir"
  attr :theme, :string, default: "vs-dark"
  attr :readonly, :boolean, default: false
  attr :class, :string, default: ""
  attr :phx_change, :string, default: nil
  attr :phx_blur, :string, default: nil
  attr :phx_focus, :string, default: nil
  attr :phx_submit, :string, default: nil
  attr :form, :any, default: nil
  attr :field, :any, default: nil
  attr :opts, :list, default: []

  def code_editor(assigns) do
    value =
      assigns[:value] ||
        if assigns.form && assigns.field do
          Form.input_value(assigns.form, assigns.field) || ""
        else
          ""
        end

    assigns = assign(assigns, :value, value)

    ~H"""
    <div id={"#{@id}-container"} class={["code-editor-container", @class]}>
      <div
        id={@id}
        phx-hook="CodeEditor"
        data-language={@language}
        data-theme={@theme}
        data-readonly={if @readonly, do: "true", else: "false"}
        data-value={@value}
        data-phx-change={@phx_change}
        data-phx-blur={@phx_blur}
        data-phx-focus={@phx_focus}
        data-phx-submit={@phx_submit}
        class="code-editor"
      >
      </div>
      <%= if @form && @field do %>
        <input type="hidden" id={"#{@id}-input"} name={Form.input_name(@form, @field)} value={@value} />
      <% else %>
        <input type="hidden" id={"#{@id}-input"} value={@value} />
      <% end %>
    </div>
    """
  end
end
