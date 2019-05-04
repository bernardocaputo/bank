defmodule GraphqlWeb.Resolvers.UserResolver do
  alias Bank.Account
  alias Bank.Auth.Login

  def create_user(%{name: _name, email: _email, password: _password} = params, _) do
    Account.create_user(params)
  end

  def login(%{email: email, password: password}, _info) do
    with {:ok, user} <- Login.login_with_email_pass(email, password),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt}}
    end
  end
end
