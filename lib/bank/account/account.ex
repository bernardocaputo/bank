defmodule Bank.Account do
  alias Bank.Repo
  alias Bank.Account.User

  def create_user(params) do
    changeset = User.changeset(params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
