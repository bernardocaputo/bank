defmodule Bank.Account do
  alias Bank.Repo
  alias Bank.Account.User

  @doc """
  Creates an user
  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t(User.t())}
  def create_user(%{name: _name, email: _email, password: _password} = params) do
    changeset = User.changeset(params)

    Repo.insert(changeset)
  end
end
