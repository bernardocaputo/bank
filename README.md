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

```mutation { openBankAccount() {
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
mutation {transferMoney(receiverUserId: ID, value:VALUE)
  {
    id
    amount
  }
}
```

`You cannot transfer out more than you currently have`


### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
