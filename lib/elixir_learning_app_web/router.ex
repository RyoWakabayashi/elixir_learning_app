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

    # Check if locale is provided in the query parameters
    locale =
      cond do
        # First priority: URL parameter
        conn.params["locale"] && conn.params["locale"] in supported_locales ->
          conn.params["locale"]

        # Second priority: Session
        get_session(conn, :locale) && get_session(conn, :locale) in supported_locales ->
          get_session(conn, :locale)

        # Third priority: Browser Accept-Language header
        true ->
          # Extract Accept-Language header and parse it
          accept_language =
            List.first(Plug.Conn.get_req_header(conn, "accept-language") || []) || ""

          # Parse the Accept-Language header to get preferred languages
          preferred_locales =
            accept_language
            |> String.split(",")
            |> Enum.map(fn lang ->
              case String.split(lang, ";") do
                [lang_code | _] -> String.trim(lang_code)
                _ -> nil
              end
            end)
            |> Enum.reject(&is_nil/1)
            |> Enum.map(fn lang ->
              # Handle both "ja-JP" format and "ja" format
              case String.split(lang, "-") do
                [lang_code | _] -> lang_code
                _ -> lang
              end
            end)

          # Find the first supported locale from the browser preferences
          Enum.find(preferred_locales, default_locale, fn lang ->
            lang in supported_locales
          end)
      end

    # Set the Gettext locale
    Gettext.put_locale(ElixirLearningAppWeb.Gettext, locale)

    # Store in session and assign for templates
    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirLearningAppWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/lessons", LessonsLive, :index
    live "/about", AboutLive, :index
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
