defmodule Bank.Account do
  alias Bank.Repo
  alias Bank.Account.User

  def create_user(params) do
    changeset = User.changeset(params)

    Repo.insert(changeset)
  end
end
