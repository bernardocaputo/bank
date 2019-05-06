defmodule Bank.Repo.Migrations.AddBankAccountsTable do
  use Ecto.Migration

  def change do
    create table(:bank_accounts) do
      add(:amount, :integer)
      add(:user_id, references(:users))

      timestamps()
    end

    create(index("bank_accounts", :user_id, unique: true))
  end
end
