defmodule BankWeb.Router do
  use BankWeb, :router

  pipeline :graphql do
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource)
    plug(Bank.Auth.Context)
  end

  forward("/graphiql", Absinthe.Plug.GraphiQL, schema: GraphqlWeb.Schema)

  scope "/" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: GraphqlWeb.Schema)
  end
end
