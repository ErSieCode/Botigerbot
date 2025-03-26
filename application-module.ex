defmodule CryptoBot.Application do
  @moduledoc """
  Main application for CryptoBot.
  """
  
  use Application
  
  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CryptoBot.Repo,
      
      # Start the Telemetry supervisor
      CryptoBotWeb.Telemetry,
      
      # Start the PubSub system
      {Phoenix.PubSub, name: CryptoBot.PubSub},
      
      # Start the Endpoint (HTTP server)
      CryptoBotWeb.Endpoint,
      
      # Start the MultiTrader
      CryptoBot.Traders.MultiTrader
    ]
    
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
