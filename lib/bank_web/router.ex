defmodule BankWeb.Router do
  use BankWeb, :router

  forward("/graphql", Absinthe.Plug, schema: GraphqlWeb.Schema)
  forward("/graphiql", Absinthe.Plug.GraphiQL, schema: GraphqlWeb.Schema)
end
