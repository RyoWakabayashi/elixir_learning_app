defmodule ElixirLearningApp.CodeExecution.Supervisor do
  @moduledoc """
  Supervisor for code execution related processes.

  This supervisor manages the processes related to code execution,
  ensuring they are properly supervised and restarted if necessary.
  """

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # Session manager for tracking and managing code execution sessions
      ElixirLearningApp.CodeExecution.SessionManager
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
