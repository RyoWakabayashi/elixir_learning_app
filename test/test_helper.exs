ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ElixirLearningApp.Repo, :manual)
Application.put_env(:phoenix_test, :base_url, ElixirLearningAppWeb.Endpoint.url())
