defmodule ElixirLearningAppWeb.Router do
  use ElixirLearningAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixirLearningAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :set_locale
  end

  # Set the locale based on the "locale" query parameter, session, or browser preference
  defp set_locale(conn, _opts) do
    # Get supported locales from config
    supported_locales =
      Application.get_env(:elixir_learning_app, ElixirLearningAppWeb.Gettext)[:locales] ||
        ["en", "ja"]

    default_locale =
      Application.get_env(:elixir_learning_app, ElixirLearningAppWeb.Gettext)[:default_locale] ||
        "en"

    # Determine locale from various sources in order of priority
    locale =
      get_locale_from_params(conn, supported_locales) ||
        get_locale_from_session(conn, supported_locales) ||
        get_locale_from_header(conn, supported_locales, default_locale)

    # Set the Gettext locale
    Gettext.put_locale(ElixirLearningAppWeb.Gettext, locale)

    # Store in session and assign for templates
    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  # Get locale from URL parameters if available and supported
  defp get_locale_from_params(conn, supported_locales) do
    if conn.params["locale"] && conn.params["locale"] in supported_locales do
      conn.params["locale"]
    end
  end

  # Get locale from session if available and supported
  defp get_locale_from_session(conn, supported_locales) do
    locale = get_session(conn, :locale)
    if locale && locale in supported_locales, do: locale
  end

  # Get locale from Accept-Language header
  defp get_locale_from_header(conn, supported_locales, default_locale) do
    # Extract Accept-Language header
    accept_language =
      List.first(Plug.Conn.get_req_header(conn, "accept-language") || []) || ""

    # Parse the Accept-Language header to get preferred languages
    preferred_locales = parse_accept_language_header(accept_language)

    # Find the first supported locale from the browser preferences
    Enum.find(preferred_locales, default_locale, fn lang ->
      lang in supported_locales
    end)
  end

  # Parse the Accept-Language header into a list of language codes
  defp parse_accept_language_header(accept_language) do
    accept_language
    |> String.split(",")
    |> Enum.map(&extract_language_code/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&normalize_language_code/1)
  end

  # Extract the language code from a language-quality pair
  defp extract_language_code(lang_quality) do
    case String.split(lang_quality, ";") do
      [lang_code | _] -> String.trim(lang_code)
      _ -> nil
    end
  end

  # Normalize language code to base language (e.g., "ja-JP" -> "ja")
  defp normalize_language_code(lang) do
    case String.split(lang, "-") do
      [lang_code | _] -> lang_code
      _ -> lang
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirLearningAppWeb do
    pipe_through :browser

    # Default route redirects to preferred language
    get "/", RedirectController, :redirect_to_language

    # Language-specific routes
    scope "/:locale" do
      live "/", HomeLive, :index
      live "/lessons", LessonsLive, :index
      live "/about", AboutLive, :index
    end

    # Development routes (not language-specific)
    if Application.compile_env(:elixir_learning_app, :dev_routes) do
      live "/code-editor-demo", CodeEditorDemoLive, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirLearningAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:elixir_learning_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ElixirLearningAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
