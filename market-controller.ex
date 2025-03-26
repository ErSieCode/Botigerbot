defmodule CryptoBotWeb.API.MarketController do
  @moduledoc """
  Controller for market data API endpoints.
  """
  
  use CryptoBotWeb, :controller
  require Logger
  
  alias CryptoBot.Exchanges.BitgetExchange
  
  @doc """
  Get market data for a symbol.
  """
  def get_market_data(conn, %{"symbol" => symbol} = params) do
    # Get API credentials from app config or database
    api_key = Application.get_env(:crypto_bot, :bitget)[:api_key]
    api_secret = Application.get_env(:crypto_bot, :bitget)[:api_secret]
    passphrase = Application.get_env(:crypto_bot, :bitget)[:passphrase]
    
    # Initialize exchange
    exchange = BitgetExchange.new(api_key, api_secret, passphrase)
    
    # Get timeframe from params or use default
    timeframe = params["timeframe"] || "15m"
    
    # Fetch OHLCV data
    case BitgetExchange.fetch_ohlcv(exchange, symbol, timeframe) do
      {:ok, candles} ->
        # Convert candles to a format suitable for the frontend
        formatted_candles = 
          candles
          |> Enum.map(fn candle ->
            %{
              timestamp: candle.timestamp,
              open: Decimal.to_float(candle.open),
              high: Decimal.to_float(candle.high),
              low: Decimal.to_float(candle.low),
              close: Decimal.to_float(candle.close),
              volume: Decimal.to_float(candle.volume)
            }
          end)
        
        conn |> json(%{success: true, data: formatted_candles})
      
      {:error, error} ->
        conn
        |> put_status(500)
        |> json(%{success: false, error: "Failed to fetch market data: #{error}"})
    end
  end
  
  @doc """
  Get available trading symbols.
  """
  def get_symbols(conn, _params) do
    # Get API credentials from app config or database
    api_key = Application.get_env(:crypto_bot, :bitget)[:api_key]
    api_secret = Application.get_env(:crypto_bot, :bitget)[:api_secret]
    passphrase = Application.get_env(:crypto_bot, :bitget)[:passphrase]
    
    # Initialize exchange
    exchange = BitgetExchange.new(api_key, api_secret, passphrase)
    
    # For demo, return static list of symbols
    symbols = [
      %{id: "BTCUSDT", name: "Bitcoin", base: "BTC", quote: "USDT"},
      %{id: "ETHUSDT", name: "Ethereum", base: "ETH", quote: "USDT"},
      %{id: "SOLUSDT", name: "Solana", base: "SOL", quote: "USDT"},
      %{id: "XRPUSDT", name: "Ripple", base: "XRP", quote: "USDT"},
      %{id: "BNBUSDT", name: "Binance Coin", base: "BNB", quote: "USDT"},
      %{id: "ADAUSDT", name: "Cardano", base: "ADA", quote: "USDT"},
      %{id: "DOGEUSDT", name: "Dogecoin", base: "DOGE", quote: "USDT"},
      %{id: "DOTUSDT", name: "Polkadot", base: "DOT", quote: "USDT"}
    ]
    
    conn |> json(%{success: true, symbols: symbols})
  end
end
