defmodule CryptoBot.Indicators do
  @moduledoc """
  Module for calculating various technical indicators for market analysis.
  """
  
  alias Decimal, as: D

  @doc """
  Calculate Relative Strength Index (RSI) for a list of prices.
  
  ## Parameters
    - prices: List of closing prices (most recent last)
    - period: RSI period (default: 14)
  
  ## Returns
    List of RSI values (most recent last)
  """
  def rsi(prices, period \\ 14) do
    # Calculate price changes
    changes = 
      prices
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [prev, current] -> D.sub(current, prev) end)
    
    # Not enough data
    if length(changes) < period do
      []
    else
      # Calculate gains and losses
      {gains, losses} = 
        changes
        |> Enum.map(fn change ->
          cond do
            D.compare(change, D.new(0)) == :gt -> {change, D.new(0)}
            true -> {D.new(0), D.abs(change)}
          end
        end)
        |> Enum.unzip()
      
      # Calculate average gain and loss for initial period
      initial_avg_gain = Enum.take(gains, period) |> Enum.sum() |> D.div(D.new(period))
      initial_avg_loss = Enum.take(losses, period) |> Enum.sum() |> D.div(D.new(period))
      
      # Calculate RSI for each period
      {_, _, rsi_values} = 
        Enum.zip(Enum.drop(gains, period), Enum.drop(losses, period))
        |> Enum.reduce({initial_avg_gain, initial_avg_loss, []}, fn {gain, loss}, {prev_avg_gain, prev_avg_loss, acc} ->
          # Smoothed averages
          avg_gain = D.add(D.mult(prev_avg_gain, D.new(period - 1)), gain) |> D.div(D.new(period))
          avg_loss = D.add(D.mult(prev_avg_loss, D.new(period - 1)), loss) |> D.div(D.new(period))
          
          # Calculate RS and RSI
          rs = if D.compare(avg_loss, D.new(0)) == :eq, do: D.new(100), else: D.div(avg_gain, avg_loss)
          rsi_value = D.new(100) |> D.sub(D.div(D.new(100), D.add(D.new(1), rs)))
          
          {avg_gain, avg_loss, [rsi_value | acc]}
        end)
      
      # Add initial RSI
      initial_rs = if D.compare(initial_avg_loss, D.new(0)) == :eq, do: D.new(100), else: D.div(initial_avg_gain, initial_avg_loss)
      initial_rsi = D.new(100) |> D.sub(D.div(D.new(100), D.add(D.new(1), initial_rs)))
      
      [initial_rsi | rsi_values] |> Enum.reverse()
    end
  end

  @doc """
  Calculate Simple Moving Average (SMA) for a list of prices.
  
  ## Parameters
    - prices: List of closing prices (most recent last)
    - period: SMA period
  
  ## Returns
    List of SMA values (most recent last)
  """
  def sma(prices, period) do
    prices
    |> Enum.chunk_every(period, 1, :discard)
    |> Enum.map(fn chunk -> 
      chunk |> Enum.sum() |> D.div(D.new(period))
    end)
  end

  @doc """
  Calculate Bollinger Bands for a list of prices.
  
  ## Parameters
    - prices: List of closing prices (most recent last)
    - period: Period for SMA calculation (default: 20)
    - stdev_multiplier: Standard deviation multiplier (default: 2)
  
  ## Returns
    {middle_band, upper_band, lower_band} - Lists of band values (most recent last)
  """
  def bollinger_bands(prices, period \\ 20, stdev_multiplier \\ 2) do
    middle_band = sma(prices, period)
    
    # Calculate standard deviation and bands
    stdev_values = 
      prices
      |> Enum.chunk_every(period, 1, :discard)
      |> Enum.map(fn chunk ->
        mean = chunk |> Enum.sum() |> D.div(D.new(period))
        
        variance = 
          chunk
          |> Enum.map(fn price -> D.pow(D.sub(price, mean), 2) end)
          |> Enum.sum()
          |> D.div(D.new(period))
        
        D.sqrt(variance)
      end)
    
    # Calculate upper and lower bands
    {upper_band, lower_band} =
      Enum.zip(middle_band, stdev_values)
      |> Enum.map(fn {mb, stdev} ->
        deviation = D.mult(stdev, D.new(stdev_multiplier))
        upper = D.add(mb, deviation)
        lower = D.sub(mb, deviation)
        {upper, lower}
      end)
      |> Enum.unzip()
    
    {middle_band, upper_band, lower_band}
  end

  @doc """
  Calculate momentum indicator for a list of prices.
  
  ## Parameters
    - prices: List of closing prices (most recent last)
    - period: Period for momentum calculation (default: 5)
  
  ## Returns
    List of momentum values (most recent last)
  """
  def momentum(prices, period \\ 5) do
    prices
    |> Enum.chunk_every(period + 1, 1, :discard)
    |> Enum.map(fn chunk -> 
      [oldest | _] = chunk
      [newest | _] = Enum.reverse(chunk)
      D.sub(newest, oldest)
    end)
  end
end
