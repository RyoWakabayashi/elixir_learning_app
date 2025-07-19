defmodule ElixirLearningAppWeb.Components.CodeOutput do
  @moduledoc """
  Component for displaying code execution output with formatting for regular output and errors.
  Includes loading indicators and line number formatting for errors.

  Features:
  - Formatted output display with syntax highlighting
  - Error message formatting with line numbers and error type highlighting
  - Loading indicators for code execution
  - Empty state display
  - Responsive design
  """
  use Phoenix.Component

  attr :id, :string, required: true, doc: "Unique identifier for the component"
  attr :output, :string, default: nil, doc: "Output from code execution"
  attr :error, :string, default: nil, doc: "Error message from code execution"
  attr :loading, :boolean, default: false, doc: "Whether code is currently executing"
  attr :class, :string, default: "", doc: "Additional CSS classes"
  attr :execution_time, :integer, default: nil, doc: "Execution time in milliseconds (optional)"

  def code_output(assigns) do
    ~H"""
    <div id={@id} class={["code-output-container", @class]} phx-update="replace">
      <%= if @loading do %>
        <div class="code-output-loading">
          <div class="code-output-loading-spinner"></div>
          <span>Executing code...</span>
        </div>
      <% else %>
        <%= if @error do %>
          <div class="code-output-error">
            <div class="code-output-header">
              <span class="code-output-status-error">Error</span>
              <%= if @execution_time do %>
                <span class="code-output-time">Execution time: {@execution_time}ms</span>
              <% end %>
            </div>
            <div class="code-output-content">
              {format_error(@error)}
            </div>
          </div>
        <% else %>
          <%= if @output do %>
            <div class="code-output-result">
              <div class="code-output-header">
                <span class="code-output-status-success">Success</span>
                <%= if @execution_time do %>
                  <span class="code-output-time">Execution time: {@execution_time}ms</span>
                <% end %>
              </div>
              <div class="code-output-content">
                <pre><code><%= format_output(@output) %></code></pre>
              </div>
            </div>
          <% else %>
            <div class="code-output-empty">
              <p>Execute code to see output</p>
            </div>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  # Format successful output with basic syntax highlighting
  defp format_output(output) do
    output
  end

  # Format error messages to include line numbers and better formatting
  defp format_error(error) do
    formatted = format_line_numbers(error)
    Phoenix.HTML.raw(formatted)
  end

  # Format error messages to highlight line numbers and add syntax highlighting
  defp format_line_numbers(error) do
    # Process each line of the error message
    lines = String.split(error, "\n")
    processed_lines = Enum.map(lines, &process_error_line/1)
    Enum.join(processed_lines, "\n")
  end

  # Process a single line of error message
  defp process_error_line(line) do
    code_snippet_regex = ~r/```(.*?)```/s

    case Regex.run(code_snippet_regex, line) do
      [_full_match, code] ->
        "<pre class=\"code-output-snippet\"><code>#{code}</code></pre>"

      nil ->
        line
        |> highlight_error_type()
        |> highlight_line_numbers()
    end
  end

  # Highlight error types in the line
  defp highlight_error_type(line) do
    error_type_regex = ~r/\*\*\s+\(([A-Za-z.]+)\)/

    case Regex.run(error_type_regex, line) do
      [full_match, error_type] ->
        String.replace(
          line,
          full_match,
          "<span class=\"code-output-error-type\" title=\"#{error_type} Error\">#{full_match}</span>"
        )

      nil ->
        line
    end
  end

  # Highlight line numbers in the line
  defp highlight_line_numbers(line) do
    # Match line number patterns in Elixir error messages
    # Examples:
    # - "** (CompileError) nofile:2:"
    # - "** (RuntimeError) error on line 5"
    # - "** (SyntaxError) nofile:3:5:"
    line_number_regex = ~r/(?:\(.*?\).*?:(\d+)(?::\d+)?:)|(?:line\s+(\d+))/

    case Regex.run(line_number_regex, line) do
      [match, line_num | _] when is_binary(line_num) and line_num != "" ->
        highlight_line_number(line, match, line_num)

      [match, _, line_num] when is_binary(line_num) and line_num != "" ->
        highlight_line_number(line, match, line_num)

      nil ->
        line
    end
  end

  # Highlight line numbers in error messages
  defp highlight_line_number(line, match, line_num) do
    # Replace the matched part with a highlighted version
    highlighted = "<span class=\"code-output-line-number\">#{match}</span>"

    # Also add a data attribute with the line number for potential future use
    # (like clicking to jump to that line in the editor)
    highlighted =
      String.replace(
        highlighted,
        "</span>",
        " data-line=\"#{line_num}\" title=\"Click to jump to line #{line_num}\"</span>"
      )

    String.replace(line, match, highlighted)
  end
end
