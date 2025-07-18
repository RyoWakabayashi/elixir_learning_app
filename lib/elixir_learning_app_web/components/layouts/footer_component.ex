defmodule ElixirLearningAppWeb.Layouts.FooterComponent do
  use ElixirLearningAppWeb, :html

  def footer(assigns) do
    ~H"""
    <footer class="bg-white mt-auto border-t border-gray-200">
      <div class="max-w-7xl mx-auto py-8 px-4 sm:py-12 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <div class="flex items-center">
              <img src={~p"/images/logo.svg"} alt="Elixir Learning App" class="h-8 w-8 text-brand" />
              <span class="ml-2 text-xl font-bold text-brand">Elixir Learning</span>
            </div>
            <p class="mt-4 text-sm text-gray-500">
              {gettext("Learn Elixir programming through interactive, hands-on lessons.")}
            </p>
          </div>

          <div class="md:col-span-2">
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              <div>
                <h3 class="text-sm font-semibold text-gray-600 tracking-wider uppercase">
                  {gettext("Navigation")}
                </h3>
                <ul class="mt-4 space-y-2">
                  <li>
                    <a
                      href="/"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      {gettext("Home")}
                    </a>
                  </li>
                  <li>
                    <a
                      href="/lessons"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      {gettext("Lessons")}
                    </a>
                  </li>
                  <li>
                    <a
                      href="/about"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      {gettext("About")}
                    </a>
                  </li>
                </ul>
              </div>

              <div>
                <h3 class="text-sm font-semibold text-gray-600 tracking-wider uppercase">
                  {gettext("Resources")}
                </h3>
                <ul class="mt-4 space-y-2">
                  <li>
                    <a
                      href="https://elixir-lang.org"
                      target="_blank"
                      rel="noopener"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      {gettext("Elixir")}
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://hexdocs.pm/phoenix_live_view"
                      target="_blank"
                      rel="noopener"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      {gettext("Phoenix LiveView")}
                    </a>
                  </li>
                </ul>
              </div>

              <div class="sm:col-span-1">
                <h3 class="text-sm font-semibold text-gray-600 tracking-wider uppercase">
                  {gettext("Language")}
                </h3>
                <ul class="mt-4 space-y-2">
                  <li>
                    <a
                      href="?locale=en"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      English
                    </a>
                  </li>
                  <li>
                    <a
                      href="?locale=ja"
                      class="text-base text-gray-500 hover:text-gray-900 transition-colors duration-200"
                    >
                      日本語
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-8 pt-8 border-t border-gray-200">
          <p class="text-center text-base text-gray-400">
            &copy; {DateTime.utc_now().year} {gettext(
              "Interactive Elixir Lessons. All rights reserved."
            )}
          </p>
        </div>
      </div>
    </footer>
    """
  end
end
