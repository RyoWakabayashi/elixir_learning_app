defmodule ElixirLearningApp.CodeExecution.CodeExecutionServiceTest do
  use ExUnit.Case, async: true
  alias ElixirLearningApp.CodeExecution.CodeExecutionService

  describe "execute/2" do
    test "executes simple code correctly" do
      assert {:ok, %{result: 2, bindings: []}} = CodeExecutionService.execute("1 + 1")
    end

    test "maintains bindings" do
      assert {:ok, %{result: 1, bindings: bindings}} = CodeExecutionService.execute("x = 1")
      assert Keyword.get(bindings, :x) == 1
    end

    test "handles syntax errors" do
      result = CodeExecutionService.execute("1 +")
      assert {:error, %{message: message}} = result

      assert String.contains?(message, "syntax error") or
               String.contains?(message, "expression is incomplete")
    end

    test "handles runtime errors" do
      result = CodeExecutionService.execute("1 / 0")
      assert {:error, %{message: message}} = result
      assert String.contains?(message, "bad argument in arithmetic expression")
    end

    test "blocks access to restricted modules" do
      result = CodeExecutionService.execute("File.read!(\"/etc/passwd\")")
      assert {:error, %{message: message, type: :security_violation}} = result
      assert String.contains?(message, "restricted modules")
    end

    test "blocks access to System module" do
      result = CodeExecutionService.execute(~s|System.cmd("ls", ["-la"])|)
      assert {:error, %{message: message, type: :security_violation}} = result
      assert String.contains?(message, "restricted modules")
    end

    test "allows safe code execution" do
      code = """
      defmodule Calculator do
        def add(a, b), do: a + b
      end

      Calculator.add(2, 3)
      """

      assert {:ok, %{result: 5}} = CodeExecutionService.execute(code)
    end

    test "handles multiple expressions" do
      code = """
      x = 10
      y = 20
      x + y
      """

      assert {:ok, %{result: 30, bindings: bindings}} = CodeExecutionService.execute(code)
      assert Keyword.get(bindings, :x) == 10
      assert Keyword.get(bindings, :y) == 20
    end
  end

  describe "contains_restricted_modules?/1" do
    test "detects File module usage" do
      assert CodeExecutionService.contains_restricted_modules?("File.read!(\"test.txt\")")
    end

    test "detects System module usage" do
      assert CodeExecutionService.contains_restricted_modules?("System.cmd(\"ls\", [])")
    end

    test "detects Code module usage" do
      assert CodeExecutionService.contains_restricted_modules?("Code.eval_string(\"1+1\")")
    end

    test "allows safe code" do
      refute CodeExecutionService.contains_restricted_modules?("Enum.map([1, 2, 3], &(&1 * 2))")
    end
  end
end
