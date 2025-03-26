defmodule CryptoBot.Exchanges.BitgetExchange do
  @moduledoc """
  Module for interacting with the Bitget Exchange API.
  Handles authentication, data fetching, and order execution.
  """
  
  require Logger
  alias Decimal, as: D
  alias CryptoBot.Exchanges.BitgetExchange
  
  @base_url "https://api.bitget.com"
  
  defstruct [:api_key, :api_secret, :passphrase]
  
  @doc """
  Create a new exchange instance with API credentials.
  """
  def new(api_key, api_secret, passphrase) do
    %BitgetExchange{
      api_key: api_key,
      api_secret: api_secret,
      passphrase: passphrase
    }
  end
  
  @doc """
  Fetch historical OHLCV (candlestick) data for a symbol.
  
  ## Parameters
    - exchange: Exchange struct
    - symbol: Trading symbol (e.g., "BTCUSDT")
    - timeframe: Candlestick timeframe (e.g., "15m", "1h", "1d")
    - limit: Maximum number of candles to fetch
  
  ## Returns
    List of maps with %{timestamp, open, high, low, close, volume}
  """
  def fetch_ohlcv(exchange, symbol, timeframe, limit \\ 200) do
    # Convert timeframe to API format
    interval = case timeframe do
      "1m" -> "1m"
      "5m" -> "5m"
      "15m" -> "15m"
      "30m" -> "30m"
      "1h" -> "1h"
      "4h" -> "4h"
      "1d" -> "1d"
      _ -> "15m" # default
    end
    
    path = "/api/v2/spot/market/candles"
    params = %{
      "symbol" => symbol,
      "interval" => interval,
      "limit" => to_string(limit)
    }
    
    case get_public(path, params) do
      {:ok, response} ->
        # Parse the response
        data = response["data"] || []
        
        candles = 
          data
          |> Enum.map(fn [timestamp, open, high, low, close, volume] ->
            %{
              timestamp: timestamp |> String.to_integer() |> DateTime.from_unix!(:millisecond),
              open: parse_decimal(open),
              high: parse_decimal(high),
              low: parse_decimal(low),
              close: parse_decimal(close),
              volume: parse_decimal(volume)
            }
          end)
        
        {:ok, candles}
        
      {:error, error} ->
        Logger.error("Failed to fetch OHLCV data: #{inspect(error)}")
        {:error, "Failed to fetch market data"}
    end
  end
  
  @doc """
  Set leverage for a symbol.
  
  ## Parameters
    - exchange: Exchange struct
    - symbol: Trading symbol (e.g., "BTCUSDT")
    - leverage: Leverage value
    - margin_coin: Margin coin (usually "USDT")
  
  ## Returns
    {:ok, response} or {:error, reason}
  """
  def set_leverage(exchange, symbol, leverage, margin_coin \\ "USDT") do
    path = "/api/mix/v1/account/setLeverage"
    params = %{
      "symbol" => symbol,
      "marginCoin" => margin_coin,
      "leverage" => to_string(leverage),
      "holdSide" => "long"
    }
    
    post_private(exchange, path, params)
  end
  
  @doc """
  Fetch account balance.
  
  ## Parameters
    - exchange: Exchange struct
  
  ## Returns
    {:ok, balance_map} or {:error, reason}
  """
  def fetch_balance(exchange) do
    path = "/api/v2/spot/account/assets"
    
    case get_private(exchange, path, %{}) do
      {:ok, response} ->
        balance_data = response["data"] || []
        
        balances =
          balance_data
          |> Enum.reduce(%{}, fn asset, acc ->
            Map.put(acc, asset["coinName"], %{
              free: parse_decimal(asset["available"]),
              used: parse_decimal(asset["frozen"]),
              total: parse_decimal(asset["total"])
            })
          end)
          
        {:ok, balances}
        
      {:error, error} ->
        Logger.error("Failed to fetch account balance: #{inspect(error)}")
        {:error, "Failed to fetch account balance"}
    end
  end
  
  @doc """
  Create a market buy order.
  
  ## Parameters
    - exchange: Exchange struct
    - symbol: Trading symbol (e.g., "BTCUSDT")
    - amount: Order quantity
    - params: Additional parameters
  
  ## Returns
    {:ok, order} or {:error, reason}
  """
  def create_market_buy_order(exchange, symbol, amount, params \\ %{}) do
    path = "/api/v2/spot/trade/market-buy"
    order_params = Map.merge(
      %{
        "symbol" => symbol,
        "quantity" => D.to_string(amount)
      },
      params
    )
    
    post_private(exchange, path, order_params)
  end
  
  @doc """
  Create a market sell order.
  
  ## Parameters
    - exchange: Exchange struct
    - symbol: Trading symbol (e.g., "BTCUSDT")
    - amount: Order quantity
    - params: Additional parameters
  
  ## Returns
    {:ok, order} or {:error, reason}
  """
  def create_market_sell_order(exchange, symbol, amount, params \\ %{}) do
    path = "/api/v2/spot/trade/market-sell"
    order_params = Map.merge(
      %{
        "symbol" => symbol,
        "quantity" => D.to_string(amount)
      },
      params
    )
    
    post_private(exchange, path, order_params)
  end
  
  # Private helpers
  
  defp get_public(path, params) do
    query = URI.encode_query(params)
    url = "#{@base_url}#{path}?#{query}"
    
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
    
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}
      
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "API error: #{status} - #{body}"}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  defp get_private(exchange, path, params) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> to_string()
    query = URI.encode_query(params)
    url = "#{@base_url}#{path}?#{query}"
    
    signature = generate_signature("GET", path, query, "", timestamp, exchange.api_secret)
    
    headers = [
      {"ACCESS-KEY", exchange.api_key},
      {"ACCESS-SIGN", signature},
      {"ACCESS-TIMESTAMP", timestamp},
      {"ACCESS-PASSPHRASE", exchange.passphrase},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
    
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}
      
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "API error: #{status} - #{body}"}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  defp post_private(exchange, path, params) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> to_string()
    payload = Jason.encode!(params)
    
    signature = generate_signature("POST", path, "", payload, timestamp, exchange.api_secret)
    
    headers = [
      {"ACCESS-KEY", exchange.api_key},
      {"ACCESS-SIGN", signature},
      {"ACCESS-TIMESTAMP", timestamp},
      {"ACCESS-PASSPHRASE", exchange.passphrase},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
    
    url = "#{@base_url}#{path}"
    
    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}
      
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "API error: #{status} - #{body}"}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  defp generate_signature(method, path, query, payload, timestamp, secret) do
    message = "#{timestamp}#{method}#{path}"
    message = if query != "", do: "#{message}?#{query}", else: message
    message = if payload != "", do: message <> payload, else: message
    
    :crypto.mac(:hmac, :sha256, secret, message)
    |> Base.encode64()
  end
  
  defp parse_decimal(value) when is_binary(value) do
    D.new(value)
  end
  
  defp parse_decimal(value) when is_integer(value) do
    D.new(value)
  end
  
  defp parse_decimal(value) when is_float(value) do
    D.from_float(value)
  end
  
  defp parse_decimal(nil), do: D.new(0)
end
