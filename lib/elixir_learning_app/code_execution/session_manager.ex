defmodule ElixirLearningApp.CodeExecution.SessionManager do
  @moduledoc """
  Manages code execution sessions for users.

  This module provides functionality for:
  - Creating new sessions
  - Tracking active sessions
  - Cleaning up expired sessions
  - Maintaining session isolation between users
  """

  use GenServer
  alias ElixirLearningApp.CodeExecution.Sandbox

  # Session timeout in milliseconds (30 minutes)
  @session_timeout 30 * 60 * 1000

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Creates a new session for a user.

  Returns the session ID that can be used for subsequent code executions.
  """
  def create_session(user_id \\ nil) do
    GenServer.call(__MODULE__, {:create_session, user_id})
  end

  @doc """
  Gets information about a specific session.
  """
  def get_session(session_id) do
    GenServer.call(__MODULE__, {:get_session, session_id})
  end

  @doc """
  Lists all active sessions.
  """
  def list_sessions do
    GenServer.call(__MODULE__, :list_sessions)
  end

  @doc """
  Terminates a session.
  """
  def terminate_session(session_id) do
    GenServer.call(__MODULE__, {:terminate_session, session_id})
  end

  @doc """
  Refreshes a session's expiration time.
  """
  def refresh_session(session_id) do
    GenServer.call(__MODULE__, {:refresh_session, session_id})
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    # Schedule periodic cleanup of expired sessions
    schedule_cleanup()

    {:ok, %{sessions: %{}}}
  end

  @impl true
  def handle_call({:create_session, user_id}, _from, state) do
    # Start a new sandbox process
    {:ok, pid} = Sandbox.start_link()

    # Get the session ID from the registry
    session_id = Registry.keys(ElixirLearningApp.CodeExecution.Registry, pid) |> List.first()

    # Create session metadata
    now = System.system_time(:millisecond)

    session = %{
      id: session_id,
      pid: pid,
      user_id: user_id,
      created_at: now,
      last_accessed_at: now,
      expires_at: now + @session_timeout
    }

    # Add to sessions map
    new_state = %{state | sessions: Map.put(state.sessions, session_id, session)}

    {:reply, {:ok, session_id}, new_state}
  end

  @impl true
  def handle_call({:get_session, session_id}, _from, state) do
    case Map.get(state.sessions, session_id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      session ->
        # Update last accessed time
        updated_session = %{session | last_accessed_at: System.system_time(:millisecond)}
        new_state = %{state | sessions: Map.put(state.sessions, session_id, updated_session)}

        {:reply, {:ok, updated_session}, new_state}
    end
  end

  @impl true
  def handle_call(:list_sessions, _from, state) do
    {:reply, {:ok, Map.values(state.sessions)}, state}
  end

  @impl true
  def handle_call({:terminate_session, session_id}, _from, state) do
    case Map.get(state.sessions, session_id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      session ->
        # Terminate the sandbox process
        if Process.alive?(session.pid) do
          Process.exit(session.pid, :normal)
        end

        # Remove from sessions map
        new_state = %{state | sessions: Map.delete(state.sessions, session_id)}

        {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_call({:refresh_session, session_id}, _from, state) do
    case Map.get(state.sessions, session_id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      session ->
        now = System.system_time(:millisecond)

        updated_session = %{
          session
          | last_accessed_at: now,
            expires_at: now + @session_timeout
        }

        new_state = %{state | sessions: Map.put(state.sessions, session_id, updated_session)}

        {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_info(:cleanup_expired_sessions, state) do
    now = System.system_time(:millisecond)

    # Filter out expired sessions
    {expired, active} =
      Enum.split_with(state.sessions, fn {_id, session} ->
        session.expires_at < now
      end)

    # Terminate expired sandbox processes
    for {_id, session} <- expired do
      if Process.alive?(session.pid) do
        Process.exit(session.pid, :normal)
      end
    end

    # Schedule next cleanup
    schedule_cleanup()

    {:noreply, %{state | sessions: Map.new(active)}}
  end

  defp schedule_cleanup do
    # Run cleanup every 5 minutes
    Process.send_after(self(), :cleanup_expired_sessions, 5 * 60 * 1000)
  end
end
