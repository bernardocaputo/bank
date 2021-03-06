defmodule Bank.CashOutEventSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Bank.BankAccountSchema

  @type t :: %__MODULE__{
          bank_account_id: integer(),
          cash_out_amount: integer()
        }

  schema "cash_out_events" do
    belongs_to(:bank_account, BankAccountSchema)
    field(:cash_out_amount, :integer)

    timestamps()
  end

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:bank_account_id, :cash_out_amount])
    |> validate_required([:bank_account_id, :cash_out_amount])
  end
end
