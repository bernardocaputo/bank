defmodule Bank.Auth.Login do
  alias Bank.Repo
  alias Bank.Account.User

  def login_with_email_pass(email, given_pass) do
    user = Repo.get_by(User, email: String.downcase(email))

    cond do
      user && Bcrypt.verify_pass(given_pass, user.encrypted_password) ->
        {:ok, user}

      user ->
        {:error, "Incorrect login credentials"}

      true ->
        {:error, :"User not found"}
    end
  end
end
