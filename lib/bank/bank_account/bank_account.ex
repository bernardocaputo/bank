defmodule Bank.BankAccount do
  alias Bank.BankAccountSchema
  alias Bank.CashOutEvent
  alias Bank.Account.User
  alias Bank.TransactionEvent
  alias Bank.Repo

  @doc """
  Creates a bank account
  """
  @spec open_bank_account(User.t()) ::
          {:ok, BankAccountSchema.t()} | {:error, Ecto.Changeset.t(BankAccountSchema.t())}
  def open_bank_account(user) do
    changeset = BankAccountSchema.changeset(%{user_id: user.id})

    Repo.insert(changeset)
  end

  def cash_out(_, value) when value <= 0, do: {:error, "value cannot be less than or equal to 0"}

  @doc """
  Cashes out from bank account
  """
  @spec cash_out(BankAccountSchema.t(), pos_integer()) ::
          {:ok, BankAccountSchema.t()} | {:error, Ecto.Changeset.t(BankAccountSchema.t())}
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

  def transfer_money(nil, _, _),
    do: {:error, "you do not have a bank account. Please open a Bank Account first"}

  def transfer_money(_, nil, _), do: {:error, "Receiver does not have a bank account"}

  @doc """
  Transfers money to bank account
  """
  @spec transfer_money(BankAccountSchema.t(), BankAccountSchema.t(), pos_integer()) ::
          {:ok, BankAccountSchema.t()} | {:error, Ecto.Changeset.t(BankAccountSchema.t())}
  def transfer_money(
        bank_account = %BankAccountSchema{amount: amount},
        bank_account_receiver = %BankAccountSchema{},
        value
      ) do
    remaining_amount = amount - value

    changeset = BankAccountSchema.new_amount_changeset(bank_account, %{amount: remaining_amount})

    if changeset.valid? do
      _transfer_money(changeset, bank_account_receiver, value)
    else
      {:error, changeset}
    end
  end

  def _transfer_money(
        changeset,
        bank_account_receiver = %BankAccountSchema{amount: amount},
        value
      ) do
    new_amount = amount + value

    receiver_changeset =
      BankAccountSchema.new_amount_changeset(bank_account_receiver, %{amount: new_amount})

    if receiver_changeset.valid? do
      transfer_transaction(changeset, receiver_changeset, value)
    else
      {:error, receiver_changeset}
    end
  end

  defp transfer_transaction(changeset, receiver_changeset, value) do
    try do
      {:ok, from_bank_account} =
        Repo.transaction(fn ->
          from_bank_account = Repo.update!(changeset)
          to_bank_account = Repo.update!(receiver_changeset)
          TransactionEvent.create_transaction_event(from_bank_account, to_bank_account, value)
          from_bank_account
        end)

      {:ok, from_bank_account |> Repo.preload(:user)}
    rescue
      e in Ecto.InvalidChangesetError ->
        {:error, e.changeset}
    end
  end
end
