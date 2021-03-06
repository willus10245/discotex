defmodule DiscotexWeb.FeatureCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  use Hound.Helpers

  alias Discotex.Repo
  alias DiscotexWeb.{Endpoint, FakeOAuthServer}
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      use Hound.Helpers

      alias Discotex.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Discotex.Factory
      import DiscotexWeb.Router.Helpers
    end
  end

  setup tags do
    Hound.start_session()

    set_window_size(current_window_handle(), 1400, 900)

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    auth_server = FakeOAuthServer.open()

    settings =
      Application.get_env(:discotex, Discotex.OAuth.GitHub)
      |> Keyword.merge(
        site: "http://localhost:#{auth_server.port}",
        authorize_url: "http://localhost:#{auth_server.port}/authorize",
        token_url: "http://localhost:#{auth_server.port}/access_token",
        redirect_uri: Endpoint.url() <> "/auth/github/callback"
      )

    Application.put_env(:discotex, Discotex.OAuth.GitHub, settings)

    {:ok, auth_server: auth_server}
  end
end
