defmodule Bank.Fixtures do
  alias Bank.Account.User
  alias Bank.BankAccount
  alias Bank.Repo

  def create_user() do
    random = 1..1_000_000 |> Enum.random()
    user = %User{email: "#{random}@email.com"} |> Repo.insert!()
    user_two = %User{email: "#email@#{random}.com"} |> Repo.insert!()
    {user, user_two}
  end

  def create_user_with_bank_account() do
    random = 1..1_000_000 |> Enum.random()
    user = %User{email: "#{random}@#{random}.com"} |> Repo.insert!()
    user_two = %User{email: "email@#{random}.com"} |> Repo.insert!()
    {:ok, bank_account} = BankAccount.open_bank_account(user)
    {:ok, bank_account_two} = BankAccount.open_bank_account(user_two)

    {bank_account |> Repo.preload(:user), bank_account_two |> Repo.preload(:user)}
  end
end
