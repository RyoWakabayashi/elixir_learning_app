defmodule ElixirLearningApp.CodeExecution.SessionManagerTest do
  use ExUnit.Case, async: false
  alias ElixirLearningApp.CodeExecution.SessionManager

  # No need for setup block since SessionManager is already started by the application

  describe "session management" do
    test "creates a new session" do
      assert {:ok, session_id} = SessionManager.create_session()
      assert is_binary(session_id)
    end

    test "gets session information" do
      {:ok, session_id} = SessionManager.create_session("test_user")
      assert {:ok, session} = SessionManager.get_session(session_id)
      assert session.id == session_id
      assert session.user_id == "test_user"
      assert is_integer(session.created_at)
      assert is_integer(session.last_accessed_at)
      assert is_integer(session.expires_at)
    end

    test "lists active sessions" do
      {:ok, session_id1} = SessionManager.create_session("user1")
      {:ok, session_id2} = SessionManager.create_session("user2")

      assert {:ok, sessions} = SessionManager.list_sessions()
      assert length(sessions) >= 2

      session_ids = Enum.map(sessions, & &1.id)
      assert session_id1 in session_ids
      assert session_id2 in session_ids
    end

    test "terminates a session" do
      {:ok, session_id} = SessionManager.create_session()
      assert :ok = SessionManager.terminate_session(session_id)
      assert {:error, :not_found} = SessionManager.get_session(session_id)
    end

    test "refreshes a session" do
      {:ok, session_id} = SessionManager.create_session()
      {:ok, session_before} = SessionManager.get_session(session_id)

      # Wait a moment to ensure timestamps differ
      :timer.sleep(10)

      assert :ok = SessionManager.refresh_session(session_id)
      {:ok, session_after} = SessionManager.get_session(session_id)

      assert session_after.last_accessed_at > session_before.last_accessed_at
      assert session_after.expires_at > session_before.expires_at
    end
  end
end
