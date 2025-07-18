defmodule ElixirLearningAppWeb.HomeLive do
  use ElixirLearningAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Interactive Elixir Lessons")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="text-center mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">Interactive Elixir Lessons</h1>
        <p class="text-xl text-gray-600">
          Learn Elixir programming through interactive, hands-on lessons
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
          <h2 class="text-2xl font-semibold text-gray-800 mb-4">Elixir Basics</h2>
          <p class="text-gray-600 mb-4">
            Start your journey with the fundamentals of Elixir programming language.
          </p>
          <a href="#" class="text-brand hover:text-brand-dark font-medium">Start Learning →</a>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
          <h2 class="text-2xl font-semibold text-gray-800 mb-4">Pattern Matching</h2>
          <p class="text-gray-600 mb-4">
            Master one of Elixir's most powerful features for elegant code.
          </p>
          <a href="#" class="text-brand hover:text-brand-dark font-medium">Start Learning →</a>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
          <h2 class="text-2xl font-semibold text-gray-800 mb-4">Phoenix LiveView</h2>
          <p class="text-gray-600 mb-4">
            Build interactive web applications with Phoenix LiveView.
          </p>
          <a href="#" class="text-brand hover:text-brand-dark font-medium">Start Learning →</a>
        </div>
      </div>
    </div>
    """
  end
end
