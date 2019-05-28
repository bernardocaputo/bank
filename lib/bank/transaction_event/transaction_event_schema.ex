defmodule Bank.TransactionEventSchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bank.BankAccountSchema

  @type t :: %__MODULE__{
          from_bank_account_id: integer(),
          to_bank_account_id: integer()
        }

  schema "transaction_events" do
    belongs_to(:from_bank_account, BankAccountSchema)
    belongs_to(:to_bank_account, BankAccountSchema)
    field(:transaction_amount, :integer)

    timestamps()
  end

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:from_bank_account_id, :to_bank_account_id, :transaction_amount])
    |> validate_required([:from_bank_account_id, :to_bank_account_id, :transaction_amount])
  end
end
