defmodule ElixirLearningAppWeb.Layouts.HeaderComponent do
  @moduledoc """
  Component for rendering the application header with navigation and language selector.
  """
  use ElixirLearningAppWeb, :html

  alias Phoenix.LiveView.JS

  def header(assigns) do
    ~H"""
    <header class="bg-white shadow-sm sticky top-0 z-30">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <.link href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}"} class="flex items-center">
                <img src={~p"/images/logo.svg"} alt="Elixir Learning App" class="h-8 w-8 text-brand" />
                <span class="ml-2 text-xl font-bold text-brand">Elixir Learning</span>
              </.link>
            </div>
            <nav class="hidden sm:ml-6 sm:flex sm:space-x-8" aria-label="Main navigation">
              <.link
                href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}"}
                class="border-transparent text-gray-500 hover:border-brand hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors duration-200"
              >
                {gettext("Home")}
              </.link>
              <.link
                href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}/lessons"}
                class="border-transparent text-gray-500 hover:border-brand hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors duration-200"
              >
                {gettext("Lessons")}
              </.link>
              <.link
                href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}/about"}
                class="border-transparent text-gray-500 hover:border-brand hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors duration-200"
              >
                {gettext("About")}
              </.link>
            </nav>
          </div>
          <div class="hidden sm:ml-6 sm:flex sm:items-center">
            <div class="relative">
              <.language_selector />
            </div>
          </div>
          <div class="-mr-2 flex items-center sm:hidden">
            <!-- Mobile menu button -->
            <button
              type="button"
              class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-brand"
              aria-expanded="false"
              phx-click={JS.toggle(to: "#mobile-menu")}
            >
              <span class="sr-only">{gettext("Open main menu")}</span>
              <.icon name="hero-bars-3-solid" class="block h-6 w-6" />
            </button>
          </div>
        </div>
      </div>

    <!-- Mobile menu, show/hide based on menu state. -->
      <div class="sm:hidden hidden" id="mobile-menu">
        <div class="pt-2 pb-3 space-y-1">
          <.link
            href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}"}
            class="bg-white border-transparent text-gray-500 hover:bg-gray-50 hover:border-brand hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium transition-colors duration-200"
          >
            {gettext("Home")}
          </.link>
          <.link
            href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}/lessons"}
            class="bg-white border-transparent text-gray-500 hover:bg-gray-50 hover:border-brand hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium transition-colors duration-200"
          >
            {gettext("Lessons")}
          </.link>
          <.link
            href={~p"/#{Gettext.get_locale(ElixirLearningAppWeb.Gettext)}/about"}
            class="bg-white border-transparent text-gray-500 hover:bg-gray-50 hover:border-brand hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium transition-colors duration-200"
          >
            {gettext("About")}
          </.link>
        </div>
        <div class="pt-4 pb-3 border-t border-gray-200">
          <div class="mt-3 space-y-1">
            <.language_selector_mobile />
          </div>
        </div>
      </div>
    </header>
    """
  end

  def language_selector(assigns) do
    ~H"""
    <div class="relative inline-block text-left">
      <div>
        <button
          type="button"
          class="inline-flex justify-center w-full rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-brand transition-colors duration-200"
          id="language-menu-button"
          aria-expanded="false"
          aria-haspopup="true"
          phx-click={JS.toggle(to: "#language-dropdown-menu")}
        >
          {current_language_name()}
          <.icon name="hero-chevron-down-solid" class="ml-2 -mr-1 h-5 w-5" />
        </button>
      </div>

      <div
        class="hidden origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 focus:outline-none z-10"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="language-menu-button"
        tabindex="-1"
        id="language-dropdown-menu"
        phx-click-away={JS.hide(to: "#language-dropdown-menu")}
      >
        <div class="py-1" role="none">
          <a
            href="#"
            onclick="switchLanguage('en')"
            class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100 transition-colors duration-200"
            role="menuitem"
            tabindex="-1"
          >
            English
          </a>
          <a
            href="#"
            onclick="switchLanguage('ja')"
            class="text-gray-700 block px-4 py-2 text-sm hover:bg-gray-100 transition-colors duration-200"
            role="menuitem"
            tabindex="-1"
          >
            日本語
          </a>
        </div>
      </div>
    </div>

    <script>
      function switchLanguage(newLocale) {
        // 現在のパスを取得
        const path = window.location.pathname;

        // パスを分解
        const segments = path.split('/').filter(segment => segment.length > 0);

        // 新しいパスを構築
        let newPath;
        if (segments.length === 0) {
          // ルートパスの場合
          newPath = '/' + newLocale;
        } else if (segments[0] === 'en' || segments[0] === 'ja') {
          // 最初のセグメントが言語の場合、それを置き換える
          segments[0] = newLocale;
          newPath = '/' + segments.join('/');
        } else {
          // 言語セグメントがない場合（通常はここには来ない）
          newPath = '/' + newLocale + path;
        }

        // 新しいパスに遷移
        window.location.href = newPath;
      }
    </script>
    """
  end

  def language_selector_mobile(assigns) do
    ~H"""
    <div class="space-y-1 px-4">
      <p class="text-gray-500 text-sm font-medium">{gettext("Language")}</p>
      <a
        href="#"
        onclick="switchLanguage('en')"
        class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100 transition-colors duration-200"
      >
        English
      </a>
      <a
        href="#"
        onclick="switchLanguage('ja')"
        class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100 transition-colors duration-200"
      >
        日本語
      </a>
    </div>
    """
  end

  defp current_language_name do
    case Gettext.get_locale(ElixirLearningAppWeb.Gettext) do
      "ja" -> "日本語"
      _ -> "English"
    end
  end

  # 使用されていない関数を削除
end
