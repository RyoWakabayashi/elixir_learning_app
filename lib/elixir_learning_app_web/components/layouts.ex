defmodule ElixirLearningAppWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ElixirLearningAppWeb, :controller` and
  `use ElixirLearningAppWeb, :live_view`.
  """
  use ElixirLearningAppWeb, :html

  # Import header and footer components
  alias ElixirLearningAppWeb.Layouts.HeaderComponent
  alias ElixirLearningAppWeb.Layouts.FooterComponent

  # Re-export header and footer functions
  defdelegate page_header(assigns), to: HeaderComponent, as: :header
  defdelegate footer(assigns), to: FooterComponent

  embed_templates "layouts/*"
end
