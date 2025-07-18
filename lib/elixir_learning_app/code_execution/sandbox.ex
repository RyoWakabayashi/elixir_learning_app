defmodule ElixirLearningApp.CodeExecution.Sandbox do
  @moduledoc """
  Provides an isolated execution environment for user code.

  This module creates a dedicated process for each user session,
  allowing code execution with state persistence between executions
  while maintaining isolation between different users.
  """

  use GenServer
  alias ElixirLearningApp.CodeExecution.CodeExecutionService

  # Client API

  @doc """
  Starts a new sandbox process for a user session.
  """
  def start_link(opts \\ []) do
    session_id = Keyword.get(opts, :session_id, generate_session_id())
    GenServer.start_link(__MODULE__, %{bindings: []}, name: via_tuple(session_id))
  end

  @doc """
  Executes code in the sandbox with the current session state.
  """
  def execute(pid, code) when is_pid(pid) do
    GenServer.call(pid, {:execute, code}, 10_000)
  end

  def execute(session_id, code) when is_binary(session_id) do
    GenServer.call(via_tuple(session_id), {:execute, code}, 10_000)
  end

  @doc """
  Resets the sandbox state.
  """
  def reset(pid) when is_pid(pid) do
    GenServer.call(pid, :reset)
  end

  def reset(session_id) when is_binary(session_id) do
    GenServer.call(via_tuple(session_id), :reset)
  end

  @doc """
  Gets the current bindings from the sandbox.
  """
  def get_bindings(pid) when is_pid(pid) do
    GenServer.call(pid, :get_bindings)
  end

  def get_bindings(session_id) when is_binary(session_id) do
    GenServer.call(via_tuple(session_id), :get_bindings)
  end

  # Server callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:execute, code}, _from, state) do
    case CodeExecutionService.execute(code, state.bindings) do
      {:ok, %{result: result, bindings: new_bindings}} ->
        {:reply, {:ok, result}, %{state | bindings: new_bindings}}

      {:error, _} = error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{bindings: []}}
  end

  @impl true
  def handle_call(:get_bindings, _from, state) do
    {:reply, {:ok, state.bindings}, state}
  end

  # Helper functions

  defp via_tuple(session_id) do
    {:via, Registry, {ElixirLearningApp.CodeExecution.Registry, session_id}}
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
