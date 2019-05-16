defmodule Bank.Repo.Migrations.CreateCashOutEventsTable do
  use Ecto.Migration

  def change do
    create table(:cash_out_events) do
      add(:bank_account_id, references(:bank_accounts))
      add(:cash_out_amount, :integer)

      timestamps
    end

    create(index("cash_out_events", [:bank_account_id]))
  end
end
