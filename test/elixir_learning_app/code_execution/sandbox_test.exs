defmodule ElixirLearningApp.CodeExecution.SandboxTest do
  use ExUnit.Case, async: true
  alias ElixirLearningApp.CodeExecution.Sandbox

  setup do
    # Start a sandbox process for testing
    {:ok, pid} = Sandbox.start_link()
    %{pid: pid}
  end

  describe "execute/2" do
    test "executes code and returns result", %{pid: pid} do
      assert {:ok, 2} = Sandbox.execute(pid, "1 + 1")
    end

    test "maintains state between executions", %{pid: pid} do
      assert {:ok, 10} = Sandbox.execute(pid, "x = 10")
      assert {:ok, 20} = Sandbox.execute(pid, "y = 20")
      assert {:ok, 30} = Sandbox.execute(pid, "x + y")
    end

    test "handles errors", %{pid: pid} do
      result = Sandbox.execute(pid, "1 / 0")
      assert {:error, %{message: message}} = result
      assert String.contains?(message, "bad argument in arithmetic expression")
    end
  end

  describe "reset/1" do
    test "resets the sandbox state", %{pid: pid} do
      assert {:ok, 10} = Sandbox.execute(pid, "x = 10")
      assert :ok = Sandbox.reset(pid)
      result = Sandbox.execute(pid, "x + 5")
      assert {:error, %{message: message}} = result

      assert String.contains?(message, "undefined variable") or
               String.contains?(message, "undefined function") or
               String.contains?(message, "compile")
    end
  end

  describe "get_bindings/1" do
    test "returns current bindings", %{pid: pid} do
      Sandbox.execute(pid, "x = 10")
      Sandbox.execute(pid, "y = 20")

      assert {:ok, bindings} = Sandbox.get_bindings(pid)
      assert Keyword.get(bindings, :x) == 10
      assert Keyword.get(bindings, :y) == 20
    end
  end

  test "isolation between sandboxes" do
    {:ok, pid1} = Sandbox.start_link()
    {:ok, pid2} = Sandbox.start_link()

    Sandbox.execute(pid1, "x = 10")
    Sandbox.execute(pid2, "x = 20")

    assert {:ok, 10} = Sandbox.execute(pid1, "x")
    assert {:ok, 20} = Sandbox.execute(pid2, "x")
  end
end
