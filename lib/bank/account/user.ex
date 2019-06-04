defmodule Bank.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bank.BankAccountSchema

  @type t :: %__MODULE__{
          name: String.t(),
          email: String.t(),
          password: String.t()
        }

  schema "users" do
    field(:email, :string)
    field(:encrypted_password, :string)
    has_one(:bank_account, BankAccountSchema)
    field(:password, :string, virtual: true)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(%{email: email} = params) do
    %__MODULE__{}
    |> cast(params, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> validate_email(email)
    |> validate_length(:name, min: 3, max: 25)
    |> validate_length(:password, min: 5, max: 20)
    |> unique_constraint(:email, downcase: true)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :encrypted_password, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  # ensure that the email looks valid
  defp validate_email(changeset, email) do
    case Regex.run(~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/, email) do
      nil ->
        %{
          changeset
          | valid?: false,
            errors: [
              {:email, {"email not valid", [format: "wrong"]}}
            ]
        }

      _ ->
        changeset
    end
  end
end
