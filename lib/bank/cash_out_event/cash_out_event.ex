defmodule Bank.CashOutEvent do
  @moduledoc false

  alias Bank.CashOutEventSchema
  alias Bank.BankAccountSchema
  alias Bank.Repo

  @doc """
  Creates cash out event
  """
  @spec create_cash_out_event(BankAccountSchema.t(), pos_integer()) :: CashOutEventSchema.t()
  def create_cash_out_event(bank_account, cash_out_amount) do
    changeset =
      CashOutEventSchema.changeset(%{
        bank_account_id: bank_account.id,
        cash_out_amount: cash_out_amount
      })

    Repo.insert!(changeset)
  end
end
