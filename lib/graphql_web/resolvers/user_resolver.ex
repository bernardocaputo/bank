defmodule GraphqlWeb.Resolvers.UserResolver do
  alias Bank.Account

  def create_user(%{name: _name, email: _email, password: _password} = params, _) do
    Account.create_user(params)
  end
end
