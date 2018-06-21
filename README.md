# Mason ![Build Status](https://travis-ci.org/spacepilots/mason.svg?branch=develop)

Mason uses superpowers to coerce maps into structs. This is helpful e.g.
when you interface a REST API and want to create a struct from the response.

```elixir
defmodule User do
  defstruct [ :user_id, :created_at ]

  def masonstruct do
    %{
      createdAt: &({ :created_at, elem(DateTime.from_unix(&1), 1) }),
      userId: &({ :user_id, &1 })
    }
  end
end

response = %{ "userId" => 123, createdAt: 1456749030 }
Mason.struct User, response # %User{created_at: #DateTime<2016-02-29 12:30:30Z>, user_id: 123}
```

## Features

* coerce to Elixir's built-in types from strings
* dynamically coerce values (e.g. timestamps to `DateTime`s)
* map keys (e.g. `createdAt` to `created_at`)
* convert string keys to atoms (e.g. `..., "age" => 29, ...` to `..., age: 29, ...`)
* convert lists

## Installation

The package can be installed by adding `mason` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mason, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mason](https://hexdocs.pm/mason).

## Contributing

* We use [gitflow](https://github.com/nvie/gitflow) (with the production branch
  being `master` and the development branch being `develop`)
* and [semantic commit messages](https://seesparkbox.com/foundry/semantic_commit_messages).
* We use [semantic versioning](https://semver.org/).
* We use pull requests and run our test suite on [Travis CI](https://travis-ci.org/spacepilots/mason).
