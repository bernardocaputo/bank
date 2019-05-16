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
    |> validate_required([:user_id])
    |> put_change(:amount, 100_000)
    |> unique_constraint(:user_id)
  end

  def cash_out_changeset(bank_account, params) do
    bank_account
    |> cast(params, [:amount])
    |> validate_required([:amount])
    |> validate_number(
      :amount,
      greater_than_or_equal_to: 0,
      message: "negative not allowed"
    )
  end
end
