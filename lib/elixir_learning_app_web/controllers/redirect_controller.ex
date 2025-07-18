defmodule ElixirLearningAppWeb.RedirectController do
  use ElixirLearningAppWeb, :controller

  def redirect_to_language(conn, _params) do
    # Get supported locales from config
    supported_locales =
      Application.get_env(:elixir_learning_app, ElixirLearningAppWeb.Gettext)[:locales] ||
        ["en", "ja"]

    default_locale =
      Application.get_env(:elixir_learning_app, ElixirLearningAppWeb.Gettext)[:default_locale] ||
        "en"

    # Determine locale from session or browser preference
    locale =
      get_locale_from_session(conn, supported_locales) ||
        get_locale_from_header(conn, supported_locales, default_locale)

    # Redirect to the home page with the appropriate locale in the path
    redirect(conn, to: "/#{locale}")
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
end
