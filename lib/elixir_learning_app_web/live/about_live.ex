defmodule ElixirLearningAppWeb.AboutLive do
  use ElixirLearningAppWeb, :live_view

  @impl true
  def mount(%{"locale" => locale} = _params, _session, socket) do
    Gettext.put_locale(ElixirLearningAppWeb.Gettext, locale)
    {:ok, assign(socket, page_title: "About", locale: locale)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-3xl mx-auto">
        <h1 class="text-3xl font-bold text-gray-900 mb-6">
          {gettext("About Interactive Elixir Lessons")}
        </h1>

        <div class="prose prose-lg max-w-none">
          <p class="mb-4">
            {gettext(
              "Interactive Elixir Lessons is a platform designed to help you learn Elixir programming through hands-on, interactive exercises."
            )}
          </p>

          <h2 class="text-2xl font-semibold text-gray-800 mt-8 mb-4">{gettext("Our Mission")}</h2>
          <p class="mb-4">
            {gettext(
              "Our mission is to make learning Elixir accessible, engaging, and effective. We believe that the best way to learn programming is by doing, which is why our platform allows you to write and execute code directly in your browser."
            )}
          </p>

          <h2 class="text-2xl font-semibold text-gray-800 mt-8 mb-4">{gettext("Features")}</h2>
          <ul class="list-disc pl-6 mb-6 space-y-2">
            <li>{gettext("Interactive code execution in your browser")}</li>
            <li>{gettext("Structured learning path from basics to advanced topics")}</li>
            <li>{gettext("Immediate feedback on your code")}</li>
            <li>{gettext("Progress tracking to monitor your learning journey")}</li>
            <li>{gettext("Support for both English and Japanese languages")}</li>
          </ul>

          <h2 class="text-2xl font-semibold text-gray-800 mt-8 mb-4">{gettext("Technology")}</h2>
          <p class="mb-4">
            {gettext(
              "This platform is built with Elixir and Phoenix LiveView, the same technologies you'll be learning about. We believe in using the tools we teach, and we hope this platform serves as an example of what you can build with these powerful technologies."
            )}
          </p>
        </div>
      </div>
    </div>
    """
  end
end
