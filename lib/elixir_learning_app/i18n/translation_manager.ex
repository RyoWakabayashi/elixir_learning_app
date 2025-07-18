defmodule ElixirLearningApp.I18n.TranslationManager do
  @moduledoc """
  The TranslationManager context.
  """

  import Ecto.Query, warn: false
  alias ElixirLearningApp.Repo
  alias ElixirLearningApp.I18n.Translation

  @supported_locales ["en", "ja"]

  @doc """
  Returns the list of supported locales.

  ## Examples

      iex> get_supported_locales()
      ["en", "ja"]

  """
  def get_supported_locales, do: @supported_locales

  @doc """
  Gets a translation by locale and key.

  Returns nil if the Translation does not exist.

  ## Examples

      iex> get_translation("en", "lesson.intro")
      %Translation{}

      iex> get_translation("en", "nonexistent")
      nil

  """
  def get_translation(locale, key) when locale in @supported_locales do
    Repo.get_by(Translation, locale: locale, key: key)
  end

  @doc """
  Gets a translation by locale and key, with fallback to English.

  Returns nil if the Translation does not exist in any supported locale.

  ## Examples

      iex> get_translation_with_fallback("ja", "lesson.intro")
      %Translation{}

  """
  def get_translation_with_fallback(locale, key) when locale in @supported_locales do
    case get_translation(locale, key) do
      nil -> get_translation("en", key)
      translation -> translation
    end
  end

  @doc """
  Creates a translation.

  ## Examples

      iex> create_translation(%{locale: "en", key: "lesson.intro", content: %{title: "Introduction"}})
      {:ok, %Translation{}}

      iex> create_translation(%{locale: "invalid", key: "lesson.intro", content: %{title: "Introduction"}})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation(attrs \\ %{}) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{content: %{title: "New Title"}})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{locale: "invalid"})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs) do
    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a translation.

  ## Examples

      iex> delete_translation(translation)
      {:ok, %Translation{}}

  """
  def delete_translation(%Translation{} = translation) do
    Repo.delete(translation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation changes.

  ## Examples

      iex> change_translation(translation)
      %Ecto.Changeset{data: %Translation{}}

  """
  def change_translation(%Translation{} = translation, attrs \\ %{}) do
    Translation.changeset(translation, attrs)
  end

  @doc """
  Gets all translations for a specific locale.

  ## Examples

      iex> get_translations_for_locale("en")
      %{
        "lesson.intro" => %{title: "Introduction"},
        "lesson.conclusion" => %{title: "Conclusion"}
      }

  """
  def get_translations_for_locale(locale) when locale in @supported_locales do
    Translation
    |> where([t], t.locale == ^locale)
    |> select([t], {t.key, t.content})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Gets translations for a lesson in the specified locale with fallback to English.

  ## Examples

      iex> get_lesson_translations("ja", "intro-to-elixir")
      %{
        title: "Elixir入門",
        description: "Elixirの基本を学びましょう"
      }

  """
  def get_lesson_translations(locale, lesson_slug) when locale in @supported_locales do
    key = "lesson.#{lesson_slug}"

    case get_translation_with_fallback(locale, key) do
      nil -> %{}
      translation -> translation.content
    end
  end
end
