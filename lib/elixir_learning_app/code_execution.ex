defmodule ElixirLearningApp.CodeExecution do
  @moduledoc """
  Context module for code execution functionality.

  This module provides the public API for code execution features.
  """

  alias ElixirLearningApp.CodeExecution.{CodeExecutionService, Sandbox, SessionManager}

  @doc """
  Executes code in a one-off manner without maintaining state.

  Use this for simple code execution where state persistence is not needed.
  """
  def execute_code(code) do
    CodeExecutionService.execute(code)
  end

  @doc """
  Creates a new session for stateful code execution.

  Returns the session ID that can be used for subsequent executions.

  ## Parameters

  - `user_id` - Optional user identifier for session tracking

  ## Returns

  - `{:ok, session_id}` - Session created successfully
  """
  def create_session(user_id \\ nil) do
    SessionManager.create_session(user_id)
  end

  @doc """
  Executes code in a specific session, maintaining state between executions.

  ## Parameters

  - `session_id` - ID of the session to execute code in
  - `code` - Elixir code to execute

  ## Returns

  - `{:ok, result}` - Code executed successfully
  - `{:error, reason}` - Execution failed
  """
  def execute_in_session(session_id, code) do
    # Refresh the session expiration time
    SessionManager.refresh_session(session_id)

    # Execute the code in the sandbox
    Sandbox.execute(session_id, code)
  end

  @doc """
  Resets the state of a session.

  ## Parameters

  - `session_id` - ID of the session to reset

  ## Returns

  - `:ok` - Session reset successfully
  - `{:error, reason}` - Reset failed
  """
  def reset_session(session_id) do
    # Refresh the session expiration time
    SessionManager.refresh_session(session_id)

    # Reset the sandbox state
    Sandbox.reset(session_id)
  end

  @doc """
  Gets the current bindings from a session.

  ## Parameters

  - `session_id` - ID of the session to get bindings from

  ## Returns

  - `{:ok, bindings}` - Bindings retrieved successfully
  - `{:error, reason}` - Retrieval failed
  """
  def get_session_bindings(session_id) do
    # Refresh the session expiration time
    SessionManager.refresh_session(session_id)

    # Get the bindings from the sandbox
    Sandbox.get_bindings(session_id)
  end

  @doc """
  Gets information about a specific session.

  ## Parameters

  - `session_id` - ID of the session to get information about

  ## Returns

  - `{:ok, session}` - Session information retrieved successfully
  - `{:error, reason}` - Retrieval failed
  """
  def get_session(session_id) do
    SessionManager.get_session(session_id)
  end

  @doc """
  Lists all active sessions.

  ## Returns

  - `{:ok, sessions}` - List of active sessions
  """
  def list_sessions do
    SessionManager.list_sessions()
  end

  @doc """
  Terminates a session.

  ## Parameters

  - `session_id` - ID of the session to terminate

  ## Returns

  - `:ok` - Session terminated successfully
  - `{:error, reason}` - Termination failed
  """
  def terminate_session(session_id) do
    SessionManager.terminate_session(session_id)
  end
end
