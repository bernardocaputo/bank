defmodule GraphqlWeb.Resolvers.BankAccountResolver do
  alias Bank.BankAccountSchema
  alias Bank.BankAccount
  alias Bank.Repo

  def open_bank_account(_, %{context: %{current_user: user}}) do
    BankAccount.open_bank_account(user)
  end

  def cash_out(%{value: value}, %{context: %{current_user: user}}) do
    bank_account = Repo.get_by!(BankAccountSchema, %{user_id: user.id})
    BankAccount.cash_out(bank_account, value)
  end

  def transfer_money(%{receiver_user_id: receiver_user_id, value: value}, %{
        context: %{current_user: user}
      }) do
    bank_account = Repo.get_by(BankAccountSchema, %{user_id: user.id})
    bank_account_receiver = Repo.get_by(BankAccountSchema, %{user_id: receiver_user_id})
    BankAccount.transfer_money(bank_account, bank_account_receiver, value)
  end
end
