defmodule Bank.Auth.GuardianSerializer do
  @moduledoc """
  Handles the Token Serializer
  """

  @behaviour Guardian.Serializer

  alias Bank.Repo
  alias Bank.Account.User

  def for_token(%User{} = user), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}
  #
  def from_token("User:" <> id) do
    user = Repo.get(User, id)

    {:ok, user}
  end

  def from_token(_), do: {:error, "Unknown resource type"}
end
