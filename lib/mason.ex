defmodule Mason do
  @moduledoc """
  Mason is a small module to help you coerce values in structs. Note:
  Since we cannot define structs in doctests we simply import the `User` module
  from in our tests (see test/mason_test.exs).
  """

  @doc """
  The struct method takes a module and some params and coerces the params into
  the struct defined in the module. You need to define a function
  `masonstruct/0` on the module which defines how to coerce the params, e.g.:

      defmodule User do
        defstruct [ :age, :size, :gpa, :active, :role, :STATUS, :created_at ]

        def masonstruct do
          %{
            age: Integer,
            gpa: Float,
            active: Boolean,
            role: Atom,
            status: &coerce_status/1,
            createdAt: &({ :created_at, elem(DateTime.from_iso8601(&1), 1) })
          }
        end

        def coerce_status(value) do
          case value do
            "active" -> { :STATUS, :online }
            _ -> { :STATUS, value }
          end
        end
      end

  # Simple coercion

  Mason expects values to be strings by default and converts them to
  Integer, Boolean, Float or Atom.

      iex> Mason.struct User, %{ age: "23", gpa: "4.0", active: "true", role: "admin" }
      %User{
        STATUS: nil,
        active: true,
        age: 23,
        created_at: nil,
        gpa: 4.0,
        role: :admin,
        size: nil
      }

  # Dynamic coercion

  You can supply a function to do the coercion. It is also possible
  to map keys this way. The function takes the value of the field as argument.

  Consider this, e.g.:

      def masonstruct do
      {
        createdAt: &({ :created_at, elem(DateTime.from_iso8601(&1), 1) })
      }
      end

      iex> user = Mason.struct User, %{ createdAt: "2016-02-29T12:30:30+00:00" }
      iex> user.created_at
      #DateTime<2016-02-29 12:30:30Z>

  # Coercing lists

  You can coerce into lists by supplying an array with the type. You can supply
  Elixir's simple types as well as a function. Lists can be nested. Consider
  the following masonstruct definition:

      def masonstruct do
      {
        available: [ Boolean ],
        dates: [ &(elem(DateTime.from_iso8601(&1), 1)) ]
      }


      iex> Mason.struct User, %{ available: [ "true", "false"] }
      %User{
        STATUS: nil,
        active: nil,
        age: nil,
        available: [true, false],
        created_at: nil,
        data: nil,
        dates: nil,
        gpa: nil,
        role: nil,
        roles: nil,
        size: nil,
        user_ids: nil
      }

      iex> user = Mason.struct User, %{ dates: [ "2016-02-29T12:30:30+00:00" ] }
      iex> List.first user.dates
      #DateTime<2016-02-29 12:30:30Z>
  """
  def struct(module, params) do
    params =
      for {key, value} <- params do
        key = if is_binary(key), do: String.to_atom(key), else: key
        type = module.masonstruct[key]

        if is_function(type) do
          type.(value)
        else
          {key, coerce(value, type)}
        end
      end

    Kernel.struct(module, params)
  end

  defp coerce(value, type) do
    cond do
      is_list(type) ->
        inner_type = List.first(type)

        for inner_value <- value do
          coerce(inner_value, inner_type)
        end

      is_function(type) ->
        type.(value)

      true ->
        case type do
          Integer -> String.to_integer(value)
          Boolean -> String.to_existing_atom(value)
          Float -> String.to_float(value)
          Atom -> String.to_atom(value)
          _ -> value
        end
    end
  end
end
