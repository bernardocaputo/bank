# Bank API

This application is a GraphQL API which simulates couple bank operations such as cash out and transactions between bank accounts.

## Getting Started

After running your project in your local machine, you need to access the GraphQL API endpoint: 

```http://localhost:4000/graphiql```

### Creating a user

To get started, you will need first to create a user:

```mutation { createUser(name: "Your Name", email: "your@email.com", password: "your-password") }```

### Logging in

Then you will need to login:

```mutation { login(email: "your@email.com", password: "your-password") }``` 

The mutation above will generate a token that is used to authenticate your user (Bearer Authentication).

Please set your header as following:

```header name: Authorization``` : ```header value: Bearer TOKEN``` 

`Insert only the letters. Leave the quote marks out (") from header value`

### Openning a Bank Account

After setting your header, you will be able to open your bank account:

```
mutation { openBankAccount() {
               id
               amount
  }
}
```
 
a Bank account will be created with a default amount of: 100000 cents (equal to 1000 BRL)

### Cashing out

To cash out a value, you need to use cashOut mutation as following:

```
mutation {cashOut(value: VALUE) {
  id
  amount
}}
```

You cannot cash out more than you currently have

### Transfering money

To transfer a value to your user, you need to use the transferMoney mutation as following:

```
mutation {transferMoney(email_account: ID, value:VALUE)
  {
    id
    amount
  }
}
```

`The email_account is the email of the user that you want to transfer money to.`

`You cannot transfer out more than you currently have`


## Prerequisites
```
OTP version: 21
Elixir version: 1.7.4
```

## Running application for development

### Running the application Locally for development
If you want to run the application locally, you must use the following version from OTP and Elixir:
```
OTP version: >= 21 (used version 21.0)
Elixir version: >= 1.7 (used version  1.7.4)
Postgres: >= 10 (used version  10.0)
```

`Make sure your postgres service is up.`
`Make sure your dev and test files have database hostname pointed to localhost.`

inside the project, run in our terminal:
```
mix local.hex --force
```
```
mix local.rebar --force
```
```
mix deps.get
```
```
mix ecto.create
```

```
mix ecto.migrate
```
```
iex -S mix phx.server
```

### Running the application using Docker
An alternative option is to use docker:

download docker at: ```https://www.docker.com/get-started```

`Make sure your dev and test files have database hostname pointed to postgres.`

#### Run the following commands:
```
docker-compose build
```
```
docker-compose run web mix ecto.create
```
```
docker-compose run web mix ecto.migrate 
```
```
docker-compose up
```

## Running the tests
The following code inside mix.exs makess it easier for running tests:
```
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
```
### Running test locally
```
mix test
```

`make sure your test.exs file is pointing database hostname to localhost`


### Running test using docker 
Run:
```
docker-compose run web mix test 
```

`make sure your test.exs file is pointing database hostname to postgres`


## Deployment

SOON

