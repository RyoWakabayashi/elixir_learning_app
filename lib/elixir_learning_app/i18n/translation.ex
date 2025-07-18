defmodule ElixirLearningApp.I18n.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field :locale, :string
    field :key, :string
    field :content, :map

    timestamps()
  end

  @required_fields ~w(locale key content)a

  @doc """
  Creates a changeset for a translation.
  """
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:locale, ["en", "ja"])
    |> unique_constraint([:locale, :key])
  end
end
