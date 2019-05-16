defmodule Bank.BankAccount do
  alias Bank.BankAccountSchema
  alias Bank.CashOutEvent
  alias Bank.Repo

  def open_bank_account(user) do
    changeset = BankAccountSchema.changeset(%{user_id: user.id})

    Repo.insert(changeset)
  end

  def cash_out(bank_account, value) do
    remaining_amount = bank_account.amount - value

    changeset = BankAccountSchema.cash_out_changeset(bank_account, %{amount: remaining_amount})

    if changeset.valid? do
      cash_out_transaction(changeset, bank_account, value)
    else
      {:error, changeset}
    end
  end

  defp cash_out_transaction(changeset, bank_account, value) do
    try do
      Repo.transaction(fn ->
        CashOutEvent.create_cash_out_event(bank_account, value)
        Repo.update!(changeset)
      end)
    rescue
      e in Ecto.InvalidChangesetError ->
        {:error, e.changeset}
    end
  end
end
