defmodule Bank.Repo.Migrations.CreateTransactionEventsTable do
  use Ecto.Migration

  def change do
    create table(:transaction_events) do
      add(:from_bank_account_id, references(:bank_accounts))
      add(:to_bank_account_id, references(:bank_accounts))
      add(:transaction_amount, :integer)

      timestamps
    end

    create(index("transaction_events", [:from_bank_account_id]))
    create(index("transaction_events", [:to_bank_account_id]))
  end
end
