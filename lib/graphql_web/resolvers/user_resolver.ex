defmodule GraphqlWeb.Resolvers.UserResolver do
  alias Bank.Account

  def create_user(%{name: name, email: email, password: password} = params, _) do
    Account.create_user(params)
  end
end
