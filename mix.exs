defmodule Gateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :gateway,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tkdecoder, path: "../tkdecoder/", in_umbrella: true},
      {:amqpx, "~> 5.3"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"}
    ]
  end
end
