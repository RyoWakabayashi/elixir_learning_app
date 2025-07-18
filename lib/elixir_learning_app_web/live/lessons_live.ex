defmodule ElixirLearningAppWeb.LessonsLive do
  use ElixirLearningAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Lessons", lessons: sample_lessons())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">{gettext("Elixir Lessons")}</h1>
        <p class="text-lg text-gray-600">
          {gettext("Choose a lesson category to start learning Elixir")}
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div
          :for={category <- lesson_categories()}
          class="bg-white rounded-lg shadow-md overflow-hidden"
        >
          <div class="p-6">
            <h2 class="text-2xl font-semibold text-gray-800 mb-4">{category.name}</h2>
            <p class="text-gray-600 mb-6">{category.description}</p>

            <div class="space-y-4">
              <div
                :for={lesson <- filter_lessons_by_category(@lessons, category.id)}
                class="border-t border-gray-100 pt-4"
              >
                <div class="flex items-center justify-between">
                  <h3 class="text-lg font-medium text-gray-800">{lesson.title}</h3>
                  <span class={"px-2 py-1 text-xs font-medium rounded-full #{difficulty_color(lesson.difficulty)}"}>
                    {difficulty_label(lesson.difficulty)}
                  </span>
                </div>
                <p class="text-gray-600 mt-1 text-sm">{lesson.description}</p>
                <div class="mt-3">
                  <a href="#" class="text-brand hover:text-brand-dark font-medium text-sm">
                    {gettext("Start Lesson")} →
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Sample data for demonstration purposes
  defp lesson_categories do
    [
      %{
        id: "basics",
        name: gettext("Elixir Basics"),
        description: gettext("Learn the fundamentals of Elixir programming")
      },
      %{
        id: "pattern_matching",
        name: gettext("Pattern Matching"),
        description: gettext("Master one of Elixir's most powerful features")
      },
      %{
        id: "processes",
        name: gettext("Processes & OTP"),
        description: gettext("Learn about Elixir's concurrency model")
      },
      %{
        id: "phoenix",
        name: gettext("Phoenix LiveView"),
        description: gettext("Build interactive web applications with Phoenix")
      }
    ]
  end

  defp sample_lessons do
    [
      %{
        id: "variables",
        category_id: "basics",
        title: gettext("Variables & Types"),
        description: gettext("Learn about Elixir's basic data types"),
        difficulty: 1
      },
      %{
        id: "functions",
        category_id: "basics",
        title: gettext("Functions"),
        description: gettext("Define and use functions in Elixir"),
        difficulty: 1
      },
      %{
        id: "modules",
        category_id: "basics",
        title: gettext("Modules"),
        description: gettext("Organize your code with modules"),
        difficulty: 2
      },
      %{
        id: "basic_pattern_matching",
        category_id: "pattern_matching",
        title: gettext("Basic Pattern Matching"),
        description: gettext("Introduction to pattern matching"),
        difficulty: 2
      },
      %{
        id: "advanced_pattern_matching",
        category_id: "pattern_matching",
        title: gettext("Advanced Pattern Matching"),
        description: gettext("Complex patterns and guards"),
        difficulty: 3
      },
      %{
        id: "processes_intro",
        category_id: "processes",
        title: gettext("Introduction to Processes"),
        description: gettext("Learn about Elixir's lightweight processes"),
        difficulty: 3
      },
      %{
        id: "genserver",
        category_id: "processes",
        title: gettext("GenServer"),
        description: gettext("Build stateful server processes"),
        difficulty: 4
      },
      %{
        id: "liveview_intro",
        category_id: "phoenix",
        title: gettext("LiveView Basics"),
        description: gettext("Introduction to Phoenix LiveView"),
        difficulty: 3
      },
      %{
        id: "liveview_components",
        category_id: "phoenix",
        title: gettext("LiveView Components"),
        description: gettext("Build reusable LiveView components"),
        difficulty: 4
      }
    ]
  end

  defp filter_lessons_by_category(lessons, category_id) do
    Enum.filter(lessons, fn lesson -> lesson.category_id == category_id end)
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
end
