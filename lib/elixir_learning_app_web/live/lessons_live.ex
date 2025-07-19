defmodule ElixirLearningAppWeb.LessonsLive do
  use ElixirLearningAppWeb, :live_view

  alias ElixirLearningApp.Lessons
  alias ElixirLearningApp.Users.UserProgressManager

  @impl true
  def mount(%{"locale" => locale} = _params, _session, socket) do
    Gettext.put_locale(ElixirLearningAppWeb.Gettext, locale)

    # For now, we'll use a session-based user ID. In a real app, this would come from authentication
    user_id = get_connect_params(socket)["user_id"] || "anonymous_user"

    lessons = Lessons.list_lessons()
    categories = Lessons.get_categories()
    difficulty_levels = Lessons.get_difficulty_levels()
    progress_summary = UserProgressManager.get_progress_summary(user_id)

    socket =
      socket
      |> assign(
        page_title: "Lessons",
        lessons: lessons,
        all_lessons: lessons,
        categories: categories,
        difficulty_levels: difficulty_levels,
        progress_summary: progress_summary,
        locale: locale,
        user_id: user_id,
        filters: %{category: nil, difficulty: nil, search: ""}
      )

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "filter",
        %{"category" => category, "difficulty" => difficulty, "search" => search},
        socket
      ) do
    filters = %{
      category: if(category == "", do: nil, else: category),
      difficulty: parse_difficulty(difficulty),
      search: search
    }

    filtered_lessons = apply_filters(socket.assigns.all_lessons, filters)

    socket =
      socket
      |> assign(filters: filters)
      |> assign(lessons: filtered_lessons)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    filters = %{category: nil, difficulty: nil, search: ""}

    socket =
      socket
      |> assign(filters: filters)
      |> assign(lessons: socket.assigns.all_lessons)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">{gettext("Elixir Lessons")}</h1>
        <p class="text-lg text-gray-600 mb-6">
          {gettext("Choose a lesson to start learning Elixir")}
        </p>
        
    <!-- Progress Summary -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-lg font-semibold text-blue-900">{gettext("Your Progress")}</h3>
              <p class="text-blue-700">
                {gettext("Completed %{completed} of %{total} lessons",
                  completed: @progress_summary.completed,
                  total: @progress_summary.total
                )}
              </p>
            </div>
            <div class="text-right">
              <div class="text-2xl font-bold text-blue-900">
                {if @progress_summary.total > 0,
                  do: round(@progress_summary.completed / @progress_summary.total * 100),
                  else: 0}%
              </div>
              <div class="text-sm text-blue-600">{gettext("Complete")}</div>
            </div>
          </div>
          
    <!-- Progress by Category -->
          <div class="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
            <div :for={{category, stats} <- @progress_summary.categories} class="text-center">
              <div class="text-sm font-medium text-blue-900 capitalize">{category}</div>
              <div class="text-xs text-blue-600">{stats.completed}/{stats.total}</div>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Filters -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">{gettext("Filter Lessons")}</h3>

        <form phx-change="filter" phx-submit="filter">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <!-- Search -->
            <div>
              <label for="search" class="block text-sm font-medium text-gray-700 mb-1">
                {gettext("Search")}
              </label>
              <input
                type="text"
                id="search"
                name="search"
                value={@filters.search}
                placeholder={gettext("Search lessons...")}
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            
    <!-- Category Filter -->
            <div>
              <label for="category" class="block text-sm font-medium text-gray-700 mb-1">
                {gettext("Category")}
              </label>
              <select
                id="category"
                name="category"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">{gettext("All Categories")}</option>
                <option
                  :for={category <- @categories}
                  value={category}
                  selected={@filters.category == category}
                >
                  {String.capitalize(category)}
                </option>
              </select>
            </div>
            
    <!-- Difficulty Filter -->
            <div>
              <label for="difficulty" class="block text-sm font-medium text-gray-700 mb-1">
                {gettext("Difficulty")}
              </label>
              <select
                id="difficulty"
                name="difficulty"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">{gettext("All Levels")}</option>
                <option
                  :for={level <- @difficulty_levels}
                  value={level}
                  selected={@filters.difficulty == level}
                >
                  {difficulty_label(level)}
                </option>
              </select>
            </div>
            
    <!-- Clear Filters -->
            <div class="flex items-end">
              <button
                type="button"
                phx-click="clear_filters"
                class="w-full px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
              >
                {gettext("Clear Filters")}
              </button>
            </div>
          </div>
        </form>
      </div>
      
    <!-- Lessons Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          :for={lesson <- @lessons}
          class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow duration-200"
        >
          <div class="p-6">
            <!-- Lesson Header -->
            <div class="flex items-start justify-between mb-3">
              <div class="flex-1">
                <h3 class="text-lg font-semibold text-gray-900 mb-1">{lesson.title}</h3>
                <div class="flex items-center space-x-2 text-sm text-gray-500">
                  <span class="capitalize">{lesson.category}</span>
                  <span>•</span>
                  <span>{gettext("Order")} {lesson.order}</span>
                </div>
              </div>
              
    <!-- Completion Status -->
              <div class="ml-4">
                {render_completion_status(assigns, lesson)}
              </div>
            </div>
            
    <!-- Description -->
            <p class="text-gray-600 text-sm mb-4 line-clamp-2">{lesson.description}</p>
            
    <!-- Lesson Metadata -->
            <div class="flex items-center justify-between mb-4">
              <span class={"px-2 py-1 text-xs font-medium rounded-full #{difficulty_color(lesson.difficulty)}"}>
                {difficulty_label(lesson.difficulty)}
              </span>

              {render_estimated_time(assigns, lesson)}
            </div>
            
    <!-- Action Button -->
            <div class="flex space-x-2">
              <.link
                navigate={~p"/#{@locale}/lessons/#{lesson.slug}"}
                class="flex-1 bg-blue-600 text-white text-center py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors duration-200"
              >
                {if lesson_completed?(assigns, lesson),
                  do: gettext("Review Lesson"),
                  else: gettext("Start Lesson")}
              </.link>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Empty State -->
      <div :if={Enum.empty?(@lessons)} class="text-center py-12">
        <div class="text-gray-400 mb-4">
          <svg class="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">{gettext("No lessons found")}</h3>
        <p class="text-gray-500 mb-4">{gettext("Try adjusting your filters to see more lessons.")}</p>
        <button
          phx-click="clear_filters"
          class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
        >
          {gettext("Clear Filters")}
        </button>
      </div>
    </div>
    """
  end

  # Helper functions for filtering and rendering

  defp apply_filters(lessons, filters) do
    lessons
    |> filter_by_search(filters.search)
    |> filter_by_category(filters.category)
    |> filter_by_difficulty(filters.difficulty)
    |> Enum.sort_by(&{&1.category, &1.order, &1.id})
  end

  defp filter_by_search(lessons, search) when is_binary(search) and search != "" do
    search_term = String.downcase(search)

    Enum.filter(lessons, fn lesson ->
      String.contains?(String.downcase(lesson.title), search_term) or
        String.contains?(String.downcase(lesson.description || ""), search_term) or
        String.contains?(String.downcase(lesson.category), search_term)
    end)
  end

  defp filter_by_search(lessons, _), do: lessons

  defp filter_by_category(lessons, category) when is_binary(category) do
    Enum.filter(lessons, fn lesson -> lesson.category == category end)
  end

  defp filter_by_category(lessons, _), do: lessons

  defp filter_by_difficulty(lessons, difficulty) when is_integer(difficulty) do
    Enum.filter(lessons, fn lesson -> lesson.difficulty == difficulty end)
  end

  defp filter_by_difficulty(lessons, _), do: lessons

  defp render_completion_status(assigns, lesson) do
    if lesson_completed?(assigns, lesson) do
      assigns = assign(assigns, :lesson, lesson)

      ~H"""
      <div class="flex items-center text-green-600">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
      """
    else
      assigns = assign(assigns, :lesson, lesson)

      ~H"""
      <div class="flex items-center text-gray-400">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      </div>
      """
    end
  end

  defp render_estimated_time(assigns, lesson) do
    case Lessons.Lesson.get_estimated_time(lesson) do
      nil ->
        assigns = assign(assigns, :lesson, lesson)

        ~H"""
        <span></span>
        """

      time ->
        assigns = assign(assigns, :time, time)

        ~H"""
        <span class="text-xs text-gray-500">
          {gettext("%{time} min", time: @time)}
        </span>
        """
    end
  end

  defp lesson_completed?(assigns, lesson) do
    # Check if lesson is completed by looking at progress summary
    # This is a simplified check - in a real app you might want to fetch individual progress
    completed_lessons = get_completed_lesson_ids(assigns.progress_summary, lesson.category)
    lesson.id in completed_lessons
  end

  defp get_completed_lesson_ids(progress_summary, category) do
    # This is a simplified implementation
    # In a real app, you'd want to store and retrieve actual completed lesson IDs
    case Map.get(progress_summary.categories, category) do
      # Placeholder - would need actual IDs
      %{completed: completed} when completed > 0 -> []
      _ -> []
    end
  end

  defp difficulty_label(level) do
    case level do
      1 -> gettext("Beginner")
      2 -> gettext("Easy")
      3 -> gettext("Intermediate")
      4 -> gettext("Advanced")
      5 -> gettext("Expert")
      _ -> gettext("Unknown")
    end
  end

  defp difficulty_color(level) do
    case level do
      1 -> "bg-green-100 text-green-800"
      2 -> "bg-blue-100 text-blue-800"
      3 -> "bg-yellow-100 text-yellow-800"
      4 -> "bg-orange-100 text-orange-800"
      5 -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp parse_difficulty(""), do: nil

  defp parse_difficulty(difficulty) when is_binary(difficulty) do
    case Integer.parse(difficulty) do
      {num, ""} -> num
      _ -> nil
    end
  end

  defp parse_difficulty(_), do: nil
end
