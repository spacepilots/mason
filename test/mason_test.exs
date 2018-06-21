defmodule MasonTest do
  use ExUnit.Case

  describe ".struct/2" do
    defmodule User do
      defstruct [
        :age,
        :size,
        :gpa,
        :active,
        :role,
        :STATUS,
        :created_at,
        :roles,
        :user_ids,
        :data,
        :available,
        :dates
      ]

      def masonstruct do
        %{
          age: Integer,
          gpa: Float,
          active: Boolean,
          role: Atom,
          status: &coerce_status/1,
          createdAt: &{:created_at, elem(DateTime.from_iso8601(&1), 1)},
          roles: [Atom],
          user_ids: [Integer],
          data: [Float],
          available: [Boolean],
          dates: [&elem(DateTime.from_iso8601(&1), 1)]
        }
      end

      def coerce_status(value) do
        case value do
          "active" -> {:STATUS, :online}
          _ -> {:STATUS, value}
        end
      end
    end

    doctest Mason

    test "coerces Atoms" do
      user = Mason.struct(User, %{role: "admin"})
      assert user == %User{role: :admin}
    end

    test "coerces Integers" do
      user = Mason.struct(User, %{age: "29"})
      assert user == %User{age: 29}
    end

    test "coerces Floats" do
      user = Mason.struct(User, %{gpa: "4.0"})
      assert user == %User{gpa: 4.0}
    end

    test "coerces boolean values" do
      user = Mason.struct(User, %{active: "true"})
      assert user == %User{active: true}
    end

    test "coerces dynamically" do
      user = Mason.struct(User, %{status: "active", upcase: true})
      assert user == %User{STATUS: :online}
    end

    test "leaves values which do not occur in the masonstruct" do
      user = Mason.struct(User, %{size: "175 cm"})
      assert user == %User{size: "175 cm"}
    end

    test "leaves values which are not in the struct" do
      user = Mason.struct(User, %{shoe_size: "42"})
      assert user == %User{}
    end

    test "transforms string keys to atoms" do
      user = Mason.struct(User, %{"size" => "175 cm"})
      assert user == %User{size: "175 cm"}
    end

    test "coerces Atoms in lists" do
      user = Mason.struct(User, %{roles: ["admin", "manager"]})
      assert user == %User{roles: [:admin, :manager]}
    end

    test "coerces Integers in lists" do
      user = Mason.struct(User, %{user_ids: ["1", "2"]})
      assert user == %User{user_ids: [1, 2]}
    end

    test "coerces Floats in lists" do
      user = Mason.struct(User, %{data: ["1.0", "2.0"]})
      assert user == %User{data: [1.0, 2.0]}
    end

    test "coerces boolean values in lists" do
      user = Mason.struct(User, %{available: ["true", "false"]})
      assert user == %User{available: [true, false]}
    end

    test "coerces dynamically in lists" do
      user = Mason.struct(User, %{dates: ["2016-02-29T12:30:30+00:00"]})
      assert user == %User{dates: [elem(DateTime.from_iso8601("2016-02-29T12:30:30+00:00"), 1)]}
    end
  end
end
