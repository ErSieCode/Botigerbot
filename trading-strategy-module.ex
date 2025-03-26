defmodule CryptoBot.Strategies.MultiIndicator do
  @moduledoc """
  Implementation of a multi-indicator trading strategy.
  Uses RSI, SMA, Bollinger Bands, and Momentum for signal generation.
  """
  
  require Logger
  alias Decimal, as: D
  alias CryptoBot.Indicators

  @doc """
  Initialize strategy with configuration parameters.
  
  ## Parameters
    - config: Map of strategy configuration parameters
  
  ## Returns
    Map with merged default and provided parameters
  """
  def init(config \\ %{}) do
    defaults = %{
      rsi_period: 14,
      rsi_overbought: 70,
      rsi_oversold: 30,
      short_sma: 20,
      long_sma: 50,
      stop_loss_percent: D.new("2.5"),
      take_profit_percent: D.new("5.5"),
      bb_period: 20,
      bb_stdev: 2,
      momentum_period: 5
    }
    
    Map.merge(defaults, config)
  end

  @doc """
  Check for trading signals based on market data.
  
  ## Parameters
    - candles: List of OHLCV candle data
    - config: Strategy configuration
  
  ## Returns
    Signal type: :long, :short, or :none
  """
  def check_trade_signals(candles, config) do
    # Extract close prices
    close_prices = Enum.map(candles, & &1.close)
    
    # Calculate indicators
    rsi_values = Indicators.rsi(close_prices, config.rsi_period)
    short_sma_values = Indicators.sma(close_prices, config.short_sma)
    long_sma_values = Indicators.sma(close_prices, config.long_sma)
    {middle_band, upper_band, lower_band} = Indicators.bollinger_bands(close_prices)
    momentum_values = Indicators.momentum(close_prices, config.momentum_period)
    
    # Get latest values
    latest_close = List.last(close_prices)
    latest_rsi = List.last(rsi_values)
    latest_short_sma = List.last(short_sma_values)
    latest_long_sma = List.last(long_sma_values)
    latest_lower_band = List.last(lower_band)
    latest_upper_band = List.last(upper_band)
    latest_momentum = List.last(momentum_values)
    
    # Check for long signal
    is_long = 
      D.compare(latest_rsi, D.new(config.rsi_oversold)) in [:lt, :eq] and
      D.compare(latest_short_sma, latest_long_sma) == :gt and
      D.compare(
        D.mult(
          D.div(
            D.sub(latest_close, latest_lower_band),
            latest_lower_band
          ),
          D.new(100)
        ),
        D.new(2.0)
      ) in [:lt, :eq] and
      D.compare(latest_momentum, D.new(0)) == :gt
    
    # Check for short signal
    is_short = 
      D.compare(latest_rsi, D.new(config.rsi_overbought)) in [:gt, :eq] and
      D.compare(latest_short_sma, latest_long_sma) == :lt and
      D.compare(
        D.mult(
          D.div(
            D.sub(latest_upper_band, latest_close),
            latest_close
          ),
          D.new(100)
        ),
        D.new(2.0)
      ) in [:lt, :eq] and
      D.compare(latest_momentum, D.new(0)) == :lt
    
    cond do
      is_long -> :long
      is_short -> :short
      true -> :none
    end
  end

  @doc """
  Check if current position should be exited.
  
  ## Parameters
    - candles: List of OHLCV candle data
    - entry_price: Position entry price
    - position_type: :long or :short
    - config: Strategy configuration
  
  ## Returns
    Boolean indicating whether to exit
  """
  def check_exit_signal(candles, entry_price, position_type, config) do
    # Extract close prices
    close_prices = Enum.map(candles, & &1.close)
    
    # Calculate indicators
    rsi_values = Indicators.rsi(close_prices, config.rsi_period)
    short_sma_values = Indicators.sma(close_prices, config.short_sma)
    long_sma_values = Indicators.sma(close_prices, config.long_sma)
    {_middle_band, upper_band, lower_band} = Indicators.bollinger_bands(close_prices)
    momentum_values = Indicators.momentum(close_prices, config.momentum_period)
    
    # Get latest values
    current_price = List.last(close_prices)
    latest_rsi = List.last(rsi_values)
    latest_short_sma = List.last(short_sma_values)
    latest_long_sma = List.last(long_sma_values)
    latest_lower_band = List.last(lower_band)
    latest_upper_band = List.last(upper_band)
    latest_momentum = List.last(momentum_values)
    
    # Calculate stop-loss and take-profit prices
    {stop_loss_price, take_profit_price} = 
      case position_type do
        :long ->
          {
            D.sub(entry_price, D.mult(entry_price, D.div(config.stop_loss_percent, D.new(100)))),
            D.add(entry_price, D.mult(entry_price, D.div(config.take_profit_percent, D.new(100))))
          }
        
        :short ->
          {
            D.add(entry_price, D.mult(entry_price, D.div(config.stop_loss_percent, D.new(100)))),
            D.sub(entry_price, D.mult(entry_price, D.div(config.take_profit_percent, D.new(100))))
          }
      end
    
    # Check for exit conditions based on position type
    case position_type do
      :long ->
        D.compare(latest_rsi, D.new(config.rsi_overbought)) in [:gt, :eq] or
        D.compare(current_price, stop_loss_price) in [:lt, :eq] or
        D.compare(current_price, take_profit_price) in [:gt, :eq] or
        (D.compare(latest_short_sma, latest_long_sma) == :lt and D.compare(current_price, entry_price) == :gt) or
        (D.compare(current_price, D.mult(latest_upper_band, D.new("0.98"))) in [:gt, :eq] and D.compare(latest_momentum, D.new(0)) == :lt)
        
      :short ->
        D.compare(latest_rsi, D.new(config.rsi_oversold)) in [:lt, :eq] or
        D.compare(current_price, stop_loss_price) in [:gt, :eq] or
        D.compare(current_price, take_profit_price) in [:lt, :eq] or
        (D.compare(latest_short_sma, latest_long_sma) == :gt and D.compare(current_price, entry_price) == :lt) or
        (D.compare(current_price, D.mult(latest_lower_band, D.new("1.02"))) in [:lt, :eq] and D.compare(latest_momentum, D.new(0)) == :gt)
    end
  end
end
