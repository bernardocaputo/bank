defmodule Bank.BankAccount do
  alias Bank.BankAccountSchema
  alias Bank.Repo

  def open_bank_account(user) do
    changeset = BankAccountSchema.changeset(%{user_id: user.id})

    Repo.insert(changeset)
  end
end
