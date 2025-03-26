defmodule CryptoBotWeb.API.TradingController do
  @moduledoc """
  Controller for trading API endpoints.
  """
  
  use CryptoBotWeb, :controller
  require Logger
  
  alias CryptoBot.Traders.MultiTrader
  alias CryptoBot.Repo
  alias CryptoBot.Schemas.Position
  alias Ecto.Changeset
  import Ecto.Query
  
  @doc """
  Start trading with provided configuration.
  """
  def start_trading(conn, params) do
    # Extract and validate configuration
    with {:ok, config} <- validate_trading_config(params) do
      case MultiTrader.start_trading(config) do
        :ok ->
          conn |> json(%{success: true, message: "Trading started"})
        
        error ->
          conn
          |> put_status(500)
          |> json(%{success: false, error: "Failed to start trading: #{inspect(error)}"})
      end
    else
      {:error, errors} ->
        conn
        |> put_status(400)
        |> json(%{success: false, errors: errors})
    end
  end
  
  @doc """
  Stop all trading activity.
  """
  def stop_trading(conn, _params) do
    case MultiTrader.stop_trading() do
      :ok ->
        conn |> json(%{success: true, message: "Trading stopped"})
      
      error ->
        conn
        |> put_status(500)
        |> json(%{success: false, error: "Failed to stop trading: #{inspect(error)}"})
    end
  end
  
  @doc """
  Get current trading status.
  """
  def get_status(conn, _params) do
    status = MultiTrader.get_status()
    conn |> json(%{success: true, data: status})
  end
  
  @doc """
  Get all positions, optionally filtered by status.
  """
  def get_positions(conn, params) do
    # Extract optional filters
    status = params["status"]
    
    # Build query
    query = 
      if status in ["open", "closed"] do
        from p in Position, where: p.status == ^String.to_existing_atom(status)
      else
        Position
      end
    
    # Add order by
    query = from p in query, order_by: [desc: p.inserted_at]
    
    # Execute query
    positions = Repo.all(query)
    
    # Return positions
    conn |> json(%{success: true, positions: positions})
  end
  
  # Private helpers
  
  defp validate_trading_config(params) do
    required_fields = ["api_key", "api_secret", "passphrase"]
    optional_fields = ["symbols", "timeframe", "leverage", "interval"]
    
    strategy_fields = [
      "rsi_period", "rsi_overbought", "rsi_oversold", 
      "short_sma", "long_sma", "stop_loss_percent", 
      "take_profit_percent"
    ]
    
    # Check for required fields
    missing_fields = 
      required_fields
      |> Enum.filter(fn field -> Map.get(params, field) == nil end)
    
    if length(missing_fields) > 0 do
      {:error, %{missing_required_fields: missing_fields}}
    else
      # Build configuration
      symbols = 
        case params["symbols"] do
          nil -> ["BTCUSDT", "ETHUSDT", "SOLUSDT", "XRPUSDT"]
          str when is_binary(str) -> String.split(str, ",")
          list when is_list(list) -> list
        end
      
      strategy_config = 
        params
        |> Map.take(strategy_fields)
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          # Convert string values to appropriate types
          parsed_value = 
            case key do
              "rsi_period" -> parse_integer(value)
              "rsi_overbought" -> parse_integer(value)
              "rsi_oversold" -> parse_integer(value)
              "short_sma" -> parse_integer(value)
              "long_sma" -> parse_integer(value)
              "stop_loss_percent" -> parse_decimal(value)
              "take_profit_percent" -> parse_decimal(value)
              _ -> value
            end
          
          Map.put(acc, String.to_existing_atom(key), parsed_value)
        end)
      
      config = %{
        api_key: params["api_key"],
        api_secret: params["api_secret"],
        passphrase: params["passphrase"],
        symbols: symbols,
        timeframe: params["timeframe"] || "15m",
        leverage: parse_integer(params["leverage"]) || 5,
        interval: parse_integer(params["interval"]) || 60_000,
        strategy: strategy_config
      }
      
      {:ok, config}
    end
  end
  
  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> nil
    end
  end
  
  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(_), do: nil
  
  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {:ok, decimal} -> decimal
      _ -> nil
    end
  end
  
  defp parse_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp parse_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp parse_decimal(_), do: nil
end
