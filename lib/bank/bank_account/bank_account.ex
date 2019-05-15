defmodule Bank.BankAccount do
  alias Bank.BankAccountSchema
  alias Bank.Repo

  def open_bank_account(user) do
    changeset = BankAccountSchema.changeset(%{user_id: user.id})

    Repo.insert(changeset)
  end

  def cash_out(bank_account, value) do
    remaining_amount = bank_account.amount - value

    changeset = BankAccountSchema.cash_out_changeset(bank_account, %{amount: remaining_amount})

    Repo.update(changeset)
  end
end
