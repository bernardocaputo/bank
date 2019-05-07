defmodule GraphqlWeb.Resolvers.BankAccountResolver do
  alias Bank.BankAccount

  def open_bank_account(_, %{context: %{current_user: user}}) do
    BankAccount.open_bank_account(user)
  end
end
