defmodule ElixirLearningApp.CodeExecutionTest do
  use ElixirLearningApp.DataCase, async: false
  alias ElixirLearningApp.CodeExecution

  describe "execute_code/1" do
    test "executes simple code correctly" do
      assert {:ok, %{result: 2}} = CodeExecution.execute_code("1 + 1")
    end

    test "handles errors" do
      result = CodeExecution.execute_code("1 +")
      assert {:error, %{message: message}} = result

      assert String.contains?(message, "syntax error") or
               String.contains?(message, "expression is incomplete")
    end
  end

  describe "session management" do
    test "creates a session and executes code in it" do
      {:ok, session_id} = CodeExecution.create_session()

      assert {:ok, 10} = CodeExecution.execute_in_session(session_id, "x = 10")
      assert {:ok, 20} = CodeExecution.execute_in_session(session_id, "y = 20")
      assert {:ok, 30} = CodeExecution.execute_in_session(session_id, "x + y")
    end

    test "resets session state" do
      {:ok, session_id} = CodeExecution.create_session()

      assert {:ok, 10} = CodeExecution.execute_in_session(session_id, "x = 10")
      assert :ok = CodeExecution.reset_session(session_id)

      result = CodeExecution.execute_in_session(session_id, "x")
      assert {:error, %{message: message}} = result

      assert String.contains?(message, "undefined variable") or
               String.contains?(message, "undefined function") or
               String.contains?(message, "compile")
    end

    test "gets session bindings" do
      {:ok, session_id} = CodeExecution.create_session()

      CodeExecution.execute_in_session(session_id, "x = 10")
      CodeExecution.execute_in_session(session_id, "y = 20")

      assert {:ok, bindings} = CodeExecution.get_session_bindings(session_id)
      assert Keyword.get(bindings, :x) == 10
      assert Keyword.get(bindings, :y) == 20
    end

    test "maintains isolation between sessions" do
      {:ok, session_id1} = CodeExecution.create_session()
      {:ok, session_id2} = CodeExecution.create_session()

      CodeExecution.execute_in_session(session_id1, "x = 10")
      CodeExecution.execute_in_session(session_id2, "x = 20")

      assert {:ok, 10} = CodeExecution.execute_in_session(session_id1, "x")
      assert {:ok, 20} = CodeExecution.execute_in_session(session_id2, "x")
    end

    test "gets session information" do
      {:ok, session_id} = CodeExecution.create_session("test_user")
      assert {:ok, session} = CodeExecution.get_session(session_id)
      assert session.id == session_id
      assert session.user_id == "test_user"
    end

    test "lists active sessions" do
      {:ok, session_id1} = CodeExecution.create_session("user1")
      {:ok, session_id2} = CodeExecution.create_session("user2")

      assert {:ok, sessions} = CodeExecution.list_sessions()
      assert length(sessions) >= 2

      session_ids = Enum.map(sessions, & &1.id)
      assert session_id1 in session_ids
      assert session_id2 in session_ids
    end

    test "terminates a session" do
      {:ok, session_id} = CodeExecution.create_session()

      # Execute some code to ensure the session is active
      CodeExecution.execute_in_session(session_id, "x = 10")

      assert :ok = CodeExecution.terminate_session(session_id)
      assert {:error, :not_found} = CodeExecution.get_session(session_id)
    end
  end
end
