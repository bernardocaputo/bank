defmodule Bank.CashOutEvent do
  alias Bank.CashOutEventSchema
  alias Bank.Repo

  def create_cash_out_event(bank_account, cash_out_amount) do
    changeset =
      CashOutEventSchema.changeset(%{
        bank_account_id: bank_account.id,
        cash_out_amount: cash_out_amount
      })

    Repo.insert!(changeset)
  end
end
