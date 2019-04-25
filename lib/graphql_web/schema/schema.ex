defmodule GraphqlWeb.Schema do
  use Absinthe.Schema
  import_types(GraphqlWeb.Schema.Types)

  query do
    field :users, list_of(:user) do
      resolve(fn _params, _info ->
        {:ok, Bank.Repo.all(Bank.User)}
      end)
    end
  end
end
