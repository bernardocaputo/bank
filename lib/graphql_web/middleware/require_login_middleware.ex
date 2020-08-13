defmodule GraphqlWeb.RequireLoginMiddleware do
  @moduledoc false

  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution

  def call(resolution, _config) do
    user = resolution.context |> Map.get(:current_user)

    case user do
      nil ->
        resolution
        |> Resolution.put_result({:error, ["not_logged_in"]})

      _ ->
        resolution
    end
  end
end
