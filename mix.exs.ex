defmodule CryptoBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_bot,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {CryptoBot.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix framework
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      
      # HTTP client for API calls
      {:httpoison, "~> 2.0"},
      
      # Crypto-specific dependencies
      {:ex_crypto, "~> 0.10.0"},  # Cryptographic functions
      {:decimal, "~> 2.0"},       # Precise decimal arithmetic
      {:statistics, "~> 0.6.2"},  # Statistical functions
      
      # Time handling
      {:timex, "~> 3.7"},
      
      # Authentication
      {:guardian, "~> 2.3"},
      {:bcrypt_elixir, "~> 3.0"},
      
      # Websockets for live data
      {:phoenix_socket, "~> 2.0"},
      
      # Other utilities
      {:cors_plug, "~> 3.0"},
      {:exconstructor, "~> 1.2.3"}, # For struct initialization
      
      # Dev tools
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
