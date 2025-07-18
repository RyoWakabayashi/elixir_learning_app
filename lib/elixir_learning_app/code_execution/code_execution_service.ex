defmodule ElixirLearningApp.CodeExecution.CodeExecutionService do
  @moduledoc """
  Service for securely executing Elixir code submitted by users.

  This service provides:
  - Secure code evaluation with timeout
  - Module restrictions for security
  - Error handling for execution failures
  - Session state management
  """

  # 5 seconds timeout
  @timeout 5000

  # List of modules that are restricted for security reasons
  @restricted_modules [
    File,
    System,
    Code,
    Port,
    Process,
    Node,
    :os,
    :net_kernel,
    :net_adm,
    :init,
    :application,
    :rpc
  ]

  @doc """
  Executes the provided Elixir code with security restrictions and timeout.

  ## Parameters

  - `code` - String containing Elixir code to execute
  - `bindings` - Optional map of variable bindings to use during execution

  ## Returns

  - `{:ok, %{result: result, bindings: new_bindings}}` - Successful execution
  - `{:error, %{message: message, type: error_type}}` - Execution error
  - `{:error, %{message: "Execution timed out"}}` - Timeout error
  - `{:error, %{message: "Code contains restricted modules"}}` - Security violation

  ## Examples

      iex> CodeExecutionService.execute("1 + 1")
      {:ok, %{result: 2, bindings: []}}

      iex> CodeExecutionService.execute("x = 1")
      {:ok, %{result: 1, bindings: [x: 1]}}

      iex> CodeExecutionService.execute("File.read!(\"/etc/passwd\")")
      {:error, %{message: "Code contains restricted modules", type: :security_violation}}
  """
  def execute(code, bindings \\ []) when is_binary(code) do
    # Convert map bindings to keyword list if needed
    bindings = normalize_bindings(bindings)

    # Check for restricted modules before execution
    if contains_restricted_modules?(code) do
      {:error,
       %{message: "Code contains restricted modules or functions", type: :security_violation}}
    else
      # Execute in a supervised task with timeout
      task =
        Task.async(fn ->
          try do
            {result, new_bindings} = Code.eval_string(code, bindings)
            {:ok, %{result: result, bindings: new_bindings}}
          rescue
            e ->
              {:error,
               %{
                 message: Exception.message(e),
                 type: error_type(e),
                 stacktrace: format_stacktrace()
               }}
          catch
            kind, reason ->
              {:error,
               %{
                 message: "#{kind}: #{inspect(reason)}",
                 type: :runtime_error
               }}
          end
        end)

      # Wait with timeout
      case Task.yield(task, @timeout) || Task.shutdown(task) do
        {:ok, result} -> result
        nil -> {:error, %{message: "Execution timed out after #{@timeout}ms", type: :timeout}}
      end
    end
  end

  @doc """
  Checks if the code contains any references to restricted modules.

  This is a simple check that looks for module names followed by a dot.
  It's not foolproof but provides a basic level of security.
  """
  def contains_restricted_modules?(code) do
    Enum.any?(@restricted_modules, fn module ->
      module_name = module |> to_string() |> String.replace_prefix("Elixir.", "")
      String.contains?(code, "#{module_name}.")
    end)
  end

  # Converts map bindings to keyword list if needed
  defp normalize_bindings(bindings) when is_map(bindings) do
    Enum.map(bindings, fn {k, v} -> {String.to_atom("#{k}"), v} end)
  end

  defp normalize_bindings(bindings) when is_list(bindings), do: bindings
  defp normalize_bindings(_), do: []

  # Determines the error type based on the exception
  defp error_type(%CompileError{}), do: :compile_error
  defp error_type(%SyntaxError{}), do: :syntax_error
  defp error_type(%ArgumentError{}), do: :argument_error
  defp error_type(%RuntimeError{}), do: :runtime_error
  defp error_type(%FunctionClauseError{}), do: :function_clause_error
  defp error_type(%UndefinedFunctionError{}), do: :undefined_function_error
  defp error_type(%ArithmeticError{}), do: :arithmetic_error
  defp error_type(_), do: :unknown_error

  # Formats the stacktrace for better error reporting
  defp format_stacktrace do
    Process.info(self(), :current_stacktrace)
    |> elem(1)
    |> Enum.filter(fn {mod, _, _, _} ->
      mod != __MODULE__ && mod != Task
    end)
    |> Enum.map(fn {mod, fun, arity, location} ->
      file = location[:file] || "unknown"
      line = location[:line] || 0
      "#{inspect(mod)}.#{fun}/#{arity} (#{file}:#{line})"
    end)
  rescue
    _ -> []
  end
end
