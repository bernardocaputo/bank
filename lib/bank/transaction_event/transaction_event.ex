defmodule Bank.TransactionEvent do
  alias Bank.TransactionEventSchema
  alias Bank.Repo

  def create_transaction_event(from_bank_account, to_bank_account, transaction_amount) do
    changeset =
      TransactionEventSchema.changeset(%{
        from_bank_account_id: from_bank_account.id,
        to_bank_account_id: to_bank_account.id,
        transaction_amount: transaction_amount
      })

    Repo.insert!(changeset)
  end
end
