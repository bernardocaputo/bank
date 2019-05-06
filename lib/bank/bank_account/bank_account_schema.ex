defmodule Bank.BankAccountSchema do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bank.Account.User

  schema "bank_accounts" do
    belongs_to(:user, User)
    field(:amount, :integer)

    timestamps()
  end

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:user_id, :amount])
    |> validate_required([:user_id, :amount])
    |> validate_number(:default_value, equal_to: 1000)
  end
end
