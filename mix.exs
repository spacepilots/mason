defmodule Mason.MixProject do
  use Mix.Project

  def project do
    [
      app: :mason,
      version: "0.1.0",
      description: "Mason uses superpowers to coerce maps into structs. This is helpful e.g. when you interface a REST API and want to create a struct from the response.",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        extras: ["README.md", "LICENSE.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["phikes"],
      links: %{"GitHub" => "https://github.com/spacepilots/mason"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
