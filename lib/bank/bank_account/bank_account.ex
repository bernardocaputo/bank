defmodule Bank.BankAccount do
  alias Bank.BankAccountSchema
  alias Bank.CashOutEvent
  alias Bank.Repo

  def open_bank_account(user) do
    changeset = BankAccountSchema.changeset(%{user_id: user.id})

    Repo.insert(changeset)
  end

  def cash_out(_, value) when value <= 0, do: {:error, "value cannot be less than or equal to 0"}

  def cash_out(bank_account, value) do
    remaining_amount = bank_account.amount - value

    changeset = BankAccountSchema.new_amount_changeset(bank_account, %{amount: remaining_amount})

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

  def transfer_money(_, _, value) when value <= 0,
    do: {:error, "value cannot be less than or equal to 0"}

  def transfer_money(sender, receiver, _) when sender == receiver,
    do: {:error, "you cannot transfer money to yourself"}

  def transfer_money(
        bank_account = %BankAccountSchema{amount: amount},
        bank_account_receiver = %BankAccountSchema{},
        value
      ) do
    amount
    remaining_amount = amount - value

    changeset = BankAccountSchema.new_amount_changeset(bank_account, %{amount: remaining_amount})

    if changeset.valid? do
      _transfer_money(changeset, bank_account_receiver, value)
    else
      {:error, changeset}
    end
  end

  def _transfer_money(changeset, bank_account_receiver, value) do
    new_amount = bank_account_receiver.amount + value

    receiver_changeset =
      BankAccountSchema.new_amount_changeset(bank_account_receiver, %{amount: new_amount})

    if receiver_changeset.valid? do
      transfer_transaction(changeset, receiver_changeset)
    else
      {:error, receiver_changeset}
    end
  end

  defp transfer_transaction(changeset, receiver_changeset) do
    try do
      Repo.transaction(fn ->
        Repo.update!(receiver_changeset)
        Repo.update!(changeset)
      end)
    rescue
      e in Ecto.InvalidChangesetError ->
        {:error, e.changeset}
    end
  end
end
