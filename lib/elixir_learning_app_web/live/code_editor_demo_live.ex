defmodule ElixirLearningAppWeb.CodeEditorDemoLive do
  use ElixirLearningAppWeb, :live_view
  alias ElixirLearningAppWeb.Components.CodeEditor
  alias ElixirLearningAppWeb.Components.CodeOutput

  @default_code """
  defmodule HelloWorld do
    def greet(name) do
      "Hello, \#{name}!"
    end
  end

  HelloWorld.greet("Elixir")
  """

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       code: @default_code,
       output: nil,
       error: nil,
       loading: false
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-4">Code Editor Demo</h1>

      <div class="mb-4">
        <.button phx-click="execute_code" class="btn-primary" disabled={@loading}>
          <%= if @loading do %>
            Executing...
          <% else %>
            Execute Code
          <% end %>
        </.button>
        <.button phx-click="reset_code" class="btn-secondary ml-2" disabled={@loading}>
          Reset Code
        </.button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div>
          <h2 class="text-lg font-semibold mb-2">Editor</h2>
          <CodeEditor.code_editor id="code-editor" value={@code} phx_change="code_changed" />
        </div>

        <div>
          <h2 class="text-lg font-semibold mb-2">Output</h2>
          <CodeOutput.code_output id="code-output" output={@output} error={@error} loading={@loading} />
        </div>
      </div>
    </div>
    """
  end

  # Group all handle_event functions together
  def handle_event("code_changed", %{"value" => code}, socket) do
    {:noreply, assign(socket, code: code)}
  end

  def handle_event("execute_code", _, socket) do
    code = socket.assigns.code

    # Set loading state
    socket = assign(socket, loading: true, output: nil, error: nil)

    # Send immediate response to show loading state
    {:noreply, socket, {:continue, {:execute_code, code}}}
  end

  def handle_event("reset_code", _, socket) do
    {:noreply, assign(socket, code: @default_code, output: nil, error: nil, loading: false)}
  end

  # Handle continue callbacks
  def handle_continue({:execute_code, code}, socket) do
    # Execute the code in a safe manner
    result = execute_code_safely(code)

    case result do
      {:ok, output} ->
        {:noreply, assign(socket, output: output, error: nil, loading: false)}

      {:error, error} ->
        {:noreply, assign(socket, output: nil, error: error, loading: false)}
    end
  end

  # Execute code in a safe manner with timeout
  defp execute_code_safely(code) do
    task =
      Task.async(fn ->
        try do
          # Create a temporary file for the code
          {:ok, file_path} = Briefly.create()
          File.write!(file_path, code)

          # Execute the code using elixir command
          case System.cmd("elixir", [file_path], stderr_to_stdout: true) do
            {output, 0} ->
              {:ok, output}

            {error, _} ->
              {:error, error}
          end
        rescue
          e -> {:error, Exception.message(e)}
        after
          # Clean up is handled by Briefly
        end
      end)

    # Wait with timeout
    case Task.yield(task, 5000) || Task.shutdown(task) do
      {:ok, result} -> result
      nil -> {:error, "Execution timed out after 5 seconds"}
    end
  end
end
