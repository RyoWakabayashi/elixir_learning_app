defmodule ElixirLearningAppWeb.LessonLive do
  use ElixirLearningAppWeb, :live_view

  alias ElixirLearningApp.CodeExecution
  alias ElixirLearningApp.Lessons
  alias ElixirLearningApp.Users.UserProgressManager

  @impl true
  def mount(%{"locale" => locale, "slug" => slug}, _session, socket) do
    Gettext.put_locale(ElixirLearningAppWeb.Gettext, locale)

    case Lessons.get_lesson_with_translations(slug, locale) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, gettext("Lesson not found"))
         |> redirect(to: ~p"/#{locale}/lessons")}

      lesson ->
        # For now, we'll use a session-based user ID. In a real app, this would come from authentication
        user_id = get_connect_params(socket)["user_id"] || "anonymous_user"

        user_progress = UserProgressManager.get_user_progress(user_id, lesson.id)
        next_lesson = Lessons.get_next_lesson(lesson)
        prev_lesson = Lessons.get_previous_lesson(lesson)

        initial_code =
          case user_progress do
            nil -> lesson.initial_code || ""
            progress -> progress.last_code || lesson.initial_code || ""
          end

        socket =
          socket
          |> assign(
            page_title: lesson.title,
            lesson: lesson,
            user_id: user_id,
            user_progress: user_progress,
            next_lesson: next_lesson,
            prev_lesson: prev_lesson,
            locale: locale,
            current_code: initial_code,
            code_output: nil,
            code_error: nil,
            is_executing: false,
            # Percentage for left panel
            panel_split: 50,
            show_instructions: true
          )

        {:ok, socket}
    end
  end

  @impl true
  def handle_event("code_changed", %{"code" => code}, socket) do
    {:noreply, assign(socket, current_code: code)}
  end

  @impl true
  def handle_event("run_code", _params, socket) do
    socket = assign(socket, is_executing: true, code_output: nil, code_error: nil)

    # Record attempt
    UserProgressManager.record_attempt(
      socket.assigns.user_id,
      socket.assigns.lesson.id,
      socket.assigns.current_code
    )

    # Execute code asynchronously
    send(self(), {:execute_code, socket.assigns.current_code})

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset_code", _params, socket) do
    initial_code = socket.assigns.lesson.initial_code || ""
    {:noreply, assign(socket, current_code: initial_code)}
  end

  @impl true
  def handle_event("toggle_instructions", _params, socket) do
    {:noreply, assign(socket, show_instructions: !socket.assigns.show_instructions)}
  end

  @impl true
  def handle_event("resize_panel", %{"split" => split_str}, socket) do
    case Integer.parse(split_str) do
      {split, ""} when split >= 20 and split <= 80 ->
        {:noreply, assign(socket, panel_split: split)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("navigate_to_lesson", %{"slug" => slug}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/#{socket.assigns.locale}/lessons/#{slug}")}
  end

  @impl true
  def handle_info({:execute_code, code}, socket) do
    case CodeExecution.execute_code(code) do
      {:ok, %{result: result}} ->
        socket =
          socket
          |> assign(is_executing: false)
          |> assign(code_output: inspect(result))
          |> assign(code_error: nil)

        {:noreply, socket}

      {:error, %{message: message}} ->
        socket =
          socket
          |> assign(is_executing: false)
          |> assign(code_output: nil)
          |> assign(code_error: message)

        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col bg-gray-50">
      <!-- Header -->
      <div class="bg-white border-b border-gray-200 px-4 py-3">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <.link navigate={~p"/#{@locale}/lessons"} class="text-blue-600 hover:text-blue-800">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 19l-7-7 7-7"
                />
              </svg>
            </.link>

            <div>
              <h1 class="text-lg font-semibold text-gray-900">{@lesson.title}</h1>
              <p :if={@lesson.description} class="text-sm text-gray-600 mb-1">
                {@lesson.description}
              </p>
              <div class="flex items-center space-x-2 text-sm text-gray-500">
                <span class="capitalize">{@lesson.category}</span>
                <span>•</span>
                <span class={"px-2 py-1 text-xs font-medium rounded-full #{difficulty_color(@lesson.difficulty)}"}>
                  {difficulty_label(@lesson.difficulty)}
                </span>
                {render_estimated_time(assigns)}
              </div>
            </div>
          </div>
          
    <!-- Navigation -->
          <div class="flex items-center space-x-2">
            <button
              :if={@prev_lesson}
              phx-click="navigate_to_lesson"
              phx-value-slug={@prev_lesson.slug}
              class="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
            >
              ← {gettext("Previous")}
            </button>

            <button
              :if={@next_lesson}
              phx-click="navigate_to_lesson"
              phx-value-slug={@next_lesson.slug}
              class="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              {gettext("Next")} →
            </button>
          </div>
        </div>
      </div>
      
    <!-- Main Content -->
      <div class="flex-1 flex overflow-hidden">
        <!-- Instructions Panel -->
        <div
          :if={@show_instructions}
          class="bg-white border-r border-gray-200 overflow-y-auto"
          style={"width: #{@panel_split}%"}
        >
          <div class="p-6">
            <!-- Lesson Content -->
            <div class="prose prose-sm max-w-none">
              {render_lesson_content(assigns)}
            </div>
            
    <!-- Progress Indicator -->
            <div class="mt-8 p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm font-medium text-gray-700">{gettext("Progress")}</span>
                <span class="text-sm text-gray-500">
                  {if @user_progress && @user_progress.completed,
                    do: gettext("Completed"),
                    else: gettext("In Progress")}
                </span>
              </div>

              <div class="text-xs text-gray-500">
                {gettext("Attempts: %{count}",
                  count: if(@user_progress, do: @user_progress.attempts, else: 0)
                )}
              </div>
            </div>
          </div>
        </div>
        
    <!-- Code Editor Panel -->
        <div
          class="flex-1 flex flex-col bg-white"
          style={if @show_instructions, do: "width: #{100 - @panel_split}%", else: "width: 100%"}
        >
          <!-- Editor Header -->
          <div class="border-b border-gray-200 px-4 py-2 flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <button
                phx-click="toggle_instructions"
                class="p-1 text-gray-500 hover:text-gray-700"
                title={
                  if @show_instructions,
                    do: gettext("Hide Instructions"),
                    else: gettext("Show Instructions")
                }
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 6h16M4 12h16M4 18h16"
                  />
                </svg>
              </button>

              <span class="text-sm font-medium text-gray-700">{gettext("Code Editor")}</span>
            </div>

            <div class="flex items-center space-x-2">
              <button
                phx-click="reset_code"
                class="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
              >
                {gettext("Reset")}
              </button>

              <button
                phx-click="run_code"
                disabled={@is_executing}
                class="px-4 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {if @is_executing, do: gettext("Running..."), else: gettext("Run Code")}
              </button>
            </div>
          </div>
          
    <!-- Code Editor -->
          <div class="flex-1 flex flex-col">
            <div class="flex-1 relative">
              <textarea
                phx-change="code_changed"
                name="code"
                class="w-full h-full p-4 font-mono text-sm bg-gray-900 text-white border-none resize-none focus:outline-none"
                placeholder="Write your Elixir code here..."
              >{@current_code}</textarea>
            </div>
            
    <!-- Output Panel -->
            <div class="h-48 border-t border-gray-200 bg-gray-900 text-white overflow-y-auto">
              <div class="p-4">
                <div class="flex items-center justify-between mb-2">
                  <span class="text-sm font-medium text-gray-300">{gettext("Output")}</span>
                  <div :if={@is_executing} class="flex items-center space-x-2">
                    <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span class="text-sm text-gray-300">{gettext("Executing...")}</span>
                  </div>
                </div>

                <div class="font-mono text-sm">
                  <div :if={@code_output} class="text-green-400">
                    <pre>{@code_output}</pre>
                  </div>

                  <div :if={@code_error} class="text-red-400">
                    <pre>{@code_error}</pre>
                  </div>

                  <div :if={!@code_output && !@code_error && !@is_executing} class="text-gray-500">
                    {gettext("Run your code to see the output here...")}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Resize Handle -->
      <div
        :if={@show_instructions}
        class="absolute top-16 bg-gray-300 hover:bg-gray-400 cursor-col-resize w-1 h-full transition-colors"
        style={"left: #{@panel_split}%"}
        phx-hook="ResizeHandle"
        id="resize-handle"
      >
      </div>
    </div>
    """
  end

  # Helper functions

  defp render_lesson_content(assigns) do
    sections = Lessons.Lesson.get_sections(assigns.lesson)
    objectives = Lessons.Lesson.get_objectives(assigns.lesson)

    assigns = assign(assigns, sections: sections, objectives: objectives)

    ~H"""
    <!-- Objectives -->
    <div :if={!Enum.empty?(@objectives)} class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
      <h3 class="text-sm font-semibold text-blue-900 mb-2">{gettext("Learning Objectives")}</h3>
      <ul class="text-sm text-blue-800 space-y-1">
        <li :for={objective <- @objectives} class="flex items-start">
          <span class="text-blue-600 mr-2">•</span>
          {objective}
        </li>
      </ul>
    </div>

    <!-- Content Sections -->
    <div :for={section <- @sections} class="mb-6">
      {render_section(assigns, section)}
    </div>
    """
  end

  defp render_section(assigns, %{"type" => "text"} = section) do
    assigns = assign(assigns, section: section)

    ~H"""
    <div class="prose prose-sm max-w-none">
      <div :if={Map.get(@section, "title")} class="font-semibold text-gray-900 mb-2">
        {@section["title"]}
      </div>
      <div class="text-gray-700 leading-relaxed">
        {@section["content"]}
      </div>
    </div>
    """
  end

  defp render_section(assigns, %{"type" => "code_snippet"} = section) do
    assigns = assign(assigns, section: section)

    ~H"""
    <div class="mb-4">
      <div :if={Map.get(@section, "title")} class="text-sm font-semibold text-gray-900 mb-2">
        {@section["title"]}
      </div>
      <div class="bg-gray-900 text-white p-4 rounded-lg overflow-x-auto">
        <pre class="text-sm"><code>{Phoenix.HTML.raw(@section["content"])}</code></pre>
      </div>
    </div>
    """
  end

  defp render_section(assigns, %{"type" => "task"} = section) do
    assigns = assign(assigns, section: section)

    ~H"""
    <div class="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
      <div class="font-semibold text-yellow-900 mb-2">
        {@section["title"]}
      </div>
      <div class="text-yellow-800 mb-3">
        {@section["description"]}
      </div>

      <div :if={Map.get(@section, "hints")} class="mt-3">
        <details class="text-sm">
          <summary class="cursor-pointer text-yellow-700 font-medium">{gettext("Hints")}</summary>
          <ul class="mt-2 text-yellow-700 space-y-1">
            <li :for={hint <- @section["hints"]} class="flex items-start">
              <span class="text-yellow-600 mr-2">💡</span>
              {hint}
            </li>
          </ul>
        </details>
      </div>
    </div>
    """
  end

  defp render_section(assigns, _section) do
    ~H"""
    <div class="text-gray-500 text-sm italic">
      {gettext("Unknown content type")}
    </div>
    """
  end

  defp render_estimated_time(assigns) do
    case Lessons.Lesson.get_estimated_time(assigns.lesson) do
      nil ->
        ~H"""
        <span></span>
        """

      time ->
        assigns = assign(assigns, :time, time)

        ~H"""
        <span>•</span>
        <span>{gettext("%{time} min", time: @time)}</span>
        """
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
end
