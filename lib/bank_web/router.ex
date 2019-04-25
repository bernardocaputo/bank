defmodule BankWeb.Router do
  use BankWeb, :router

  forward(
    "/graphiql",
    Absinthe.Plug.GraphiQL,
    schema: GraphqlWeb.Schema
  )

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", BankWeb do
    pipe_through(:api)
  end
end
