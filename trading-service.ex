defmodule CryptoBot.Traders.MultiTrader do
  @moduledoc """
  Service to execute trading on multiple cryptocurrencies.
  Manages positions, analyzes market data, and executes trades.
  """
  
  use GenServer
  require Logger
  alias Decimal, as: D
  alias CryptoBot.Exchanges.BitgetExchange
  alias CryptoBot.Strategies.MultiIndicator
  alias CryptoBot.Repo
  alias CryptoBot.Traders.Position
  
  # Client API
  
  @doc """
  Start the trading service.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc """
  Start trading with the specified configuration.
  """
  def start_trading(config) do
    GenServer.call(__MODULE__, {:start_trading, config})
  end
  
  @doc """
  Stop trading.
  """
  def stop_trading do
    GenServer.call(__MODULE__, :stop_trading)
  end
  
  @doc """
  Get current trading status and positions.
  """
  def get_status do
    GenServer.call(__MODULE__, :get_status)
  end
  
  # Server implementation
  
  @impl true
  def init(opts) do
    state = %{
      trading: false,
      exchange: nil,
      symbols: [],
      timeframe: "15m",
      strategy_config: %{},
      leverage: 5,
      positions: %{},
      status: %{},
      timer_ref: nil
    }
    
    {:ok, state}
  end
  
  @impl true
  def handle_call({:start_trading, config}, _from, state) do
    # Extract and validate configuration
    api_key = config[:api_key]
    api_secret = config[:api_secret]
    passphrase = config[:passphrase]
    symbols = config[:symbols] || ["BTCUSDT", "ETHUSDT", "SOLUSDT", "XRPUSDT"]
    timeframe = config[:timeframe] || "15m"
    leverage = config[:leverage] || 5
    
    # Initialize exchange
    exchange = BitgetExchange.new(api_key, api_secret, passphrase)
    
    # Initialize positions
    positions = 
      symbols
      |> Enum.reduce(%{}, fn symbol, acc ->
        Map.put(acc, symbol, %{
          in_position: false,
          position_type: nil,
          entry_price: nil,
          position_size: D.new(0)
        })
      end)
    
    # Initialize strategy config
    strategy_config = MultiIndicator.init(config[:strategy] || %{})
    
    # Schedule periodic market check
    timer_ref = schedule_market_check(config[:interval] || 60_000)
    
    # Set leverage for all symbols
    Enum.each(symbols, fn symbol ->
      case BitgetExchange.set_leverage(exchange, symbol, leverage) do
        {:ok, _} -> Logger.info("Set leverage for #{symbol} to #{leverage}x")
        {:error, error} -> Logger.error("Failed to set leverage for #{symbol}: #{error}")
      end
    end)
    
    new_state = %{
      state |
      trading: true,
      exchange: exchange,
      symbols: symbols,
      timeframe: timeframe,
      strategy_config: strategy_config,
      leverage: leverage,
      positions: positions,
      status: %{
        started_at: DateTime.utc_now(),
        trades_executed: 0,
        profitable_trades: 0,
        total_profit_loss: D.new(0)
      },
      timer_ref: timer_ref
    }
    
    Logger.info("Trading started for symbols: #{Enum.join(symbols, ", ")}")
    
    {:reply, :ok, new_state}
  end
  
  @impl true
  def handle_call(:stop_trading, _from, state) do
    # Cancel scheduled checks
    if state.timer_ref do
      Process.cancel_timer(state.timer_ref)
    end
    
    # Close all open positions if needed
    # ...
    
    new_state = %{
      state |
      trading: false,
      timer_ref: nil
    }
    
    Logger.info("Trading stopped")
    
    {:reply, :ok, new_state}
  end
  
  @impl true
  def handle_call(:get_status, _from, state) do
    status = %{
      trading: state.trading,
      symbols: state.symbols,
      positions: state.positions,
      stats: state.status
    }
    
    {:reply, status, state}
  end
  
  @impl true
  def handle_info(:check_markets, state) do
    if state.trading do
      new_state = check_all_markets(state)
      timer_ref = schedule_market_check(60_000) # Check every minute
      
      {:noreply, %{new_state | timer_ref: timer_ref}}
    else
      {:noreply, state}
    end
  end
  
  # Helper functions
  
  defp schedule_market_check(interval) do
    Process.send_after(self(), :check_markets, interval)
  end
  
  defp check_all_markets(state) do
    # Process each symbol
    updated_positions = 
      state.symbols
      |> Enum.reduce(state.positions, fn symbol, positions ->
        process_symbol(symbol, positions, state)
      end)
    
    %{state | positions: updated_positions}
  end
  
  defp process_symbol(symbol, positions, state) do
    position = positions[symbol]
    
    # Fetch market data
    case BitgetExchange.fetch_ohlcv(state.exchange, symbol, state.timeframe) do
      {:ok, candles} ->
        if position.in_position do
          # Check for exit signal
          if MultiIndicator.check_exit_signal(
            candles, 
            position.entry_price, 
            position.position_type, 
            state.strategy_config
          ) do
            # Close position
            close_position(symbol, position, state, candles)
            
            # Update position state
            updated_position = %{
              in_position: false,
              position_type: nil,
              entry_price: nil,
              position_size: D.new(0)
            }
            
            Map.put(positions, symbol, updated_position)
          else
            # Keep position
            positions
          end
        else
          # Check for entry signal
          signal = MultiIndicator.check_trade_signals(candles, state.strategy_config)
          
          case signal do
            :long ->
              # Open long position
              new_position = open_position(symbol, :long, state, candles)
              Map.put(positions, symbol, new_position)
              
            :short ->
              # Open short position
              new_position = open_position(symbol, :short, state, candles)
              Map.put(positions, symbol, new_position)
              
            :none ->
              # No signal
              positions
          end
        end
        
      {:error, error} ->
        Logger.error("Failed to fetch data for #{symbol}: #{error}")
        positions
    end
  end
  
  defp open_position(symbol, position_type, state, candles) do
    # Get current price from candles
    current_price = List.last(candles).close
    
    # Calculate position size (risk-based)
    position_size = calculate_position_size(state, current_price, state.strategy_config.stop_loss_percent)
    
    # Execute order based on position type
    result = 
      case position_type do
        :long ->
          BitgetExchange.create_market_buy_order(state.exchange, symbol, position_size)
        
        :short ->
          BitgetExchange.create_market_sell_order(state.exchange, symbol, position_size)
      end
    
    case result do
      {:ok, order} ->
        Logger.info("Opened #{position_type} position for #{symbol} at #{D.to_string(current_price)} with size #{D.to_string(position_size)}")
        
        # Return updated position data
        %{
          in_position: true,
          position_type: position_type,
          entry_price: current_price,
          position_size: position_size
        }
      
      {:error, error} ->
        Logger.error("Failed to open position for #{symbol}: #{error}")
        
        # Return unchanged position
        %{
          in_position: false,
          position_type: nil,
          entry_price: nil,
          position_size: D.new(0)
        }
    end
  end
  
  defp close_position(symbol, position, state, candles) do
    # Get current price from candles
    current_price = List.last(candles).close
    
    # Execute order based on position type
    result = 
      case position.position_type do
        :long ->
          BitgetExchange.create_market_sell_order(state.exchange, symbol, position.position_size)
        
        :short ->
          BitgetExchange.create_market_buy_order(state.exchange, symbol, position.position_size)
      end
    
    case result do
      {:ok, order} ->
        # Calculate profit/loss
        profit_loss = 
          case position.position_type do
            :long ->
              D.sub(current_price, position.entry_price)
              |> D.div(position.entry_price)
              |> D.mult(D.new(100))
            
            :short ->
              D.sub(position.entry_price, current_price)
              |> D.div(position.entry_price)
              |> D.mult(D.new(100))
          end
        
        is_profitable = D.compare(profit_loss, D.new(0)) == :gt
        
        # Log position closing
        Logger.info("Closed #{position.position_type} position for #{symbol} at #{D.to_string(current_price)}")
        Logger.info("Profit/Loss: #{D.to_string(profit_loss)}%")
        
        # TODO: Update statistics in the state
        # ...
        
        {:ok, profit_loss}
      
      {:error, error} ->
        Logger.error("Failed to close position for #{symbol}: #{error}")
        {:error, "Failed to close position"}
    end
  end
  
  defp calculate_position_size(state, current_price, stop_loss_percent) do
    # Get account balance (if available)
    balance = 
      case BitgetExchange.fetch_balance(state.exchange) do
        {:ok, balance_data} ->
          balance_data["USDT"]["free"] || D.new(1000) # Default if not found
        {:error, _} ->
          D.new(1000) # Default balance if fetch fails
      end
    
    # Risk 2% of available balance per trade
    risk_amount = D.mult(balance, D.new("0.02"))
    
    # Calculate position size based on stop loss
    risk_per_unit = D.mult(current_price, D.div(stop_loss_percent, D.new(100)))
    
    # Position size = risk amount / risk per unit
    position_size = D.div(risk_amount, risk_per_unit)
    
    # Round to appropriate decimal places (adjust based on symbol)
    position_size
    |> D.round(4)
    |> D.mult(D.new(state.leverage)) # Apply leverage
  end
end
