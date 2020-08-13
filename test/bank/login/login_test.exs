defmodule Bank.LoginTest do
  use BankWeb.ConnCase
  alias Bank.Fixtures

  @query """
  mutation login($password: String!, $email: String!) {
    login(email: $email, password: $password)
  }
  """

  setup do
    {user, _user2} = Fixtures.create_user()

    %{user: user}
  end

  describe "logs in" do
    test "should create user", %{user: user} do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            password: "password",
            email: user.email
          }
        )

      assert response["data"]["login"]["token"] != nil
    end
  end

  describe "should not login" do
    test "when password is wrong", %{user: user} do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            password: "wrong_password",
            email: user.email
          }
        )

      [error] = response["errors"]
      assert error["message"] == "Incorrect login credentials"
    end

    test "when user does not exist" do
      response =
        build_conn()
        |> graphql_query(
          query: @query,
          variables: %{
            password: "wrong_password",
            email: "non_exist_email@email.com"
          }
        )

      [error] = response["errors"]
      assert error["message"] == "User not found"
    end
  end
end
