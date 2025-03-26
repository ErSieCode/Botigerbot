// src/stores/tradingStore.js
import { writable, derived } from 'svelte/store';
import { tradingService, marketService } from '../utils/api';

// Trading Status Store
export const tradingStatus = writable({
  loading: false,
  trading: false,
  symbols: [],
  positions: {},
  stats: {},
  error: null
});

// Positions Store
export const positions = writable({
  loading: false,
  data: [],
  error: null
});

// Market Data Store
export const marketData = writable({
  symbol: 'BTCUSDT',
  timeframe: '15m',
  loading: false,
  candles: [],
  error: null
});

// Available Symbols Store
export const symbols = writable({
  loading: false,
  data: [],
  error: null
});

// Trading Form Store
export const tradingForm = writable({
  api_key: '',
  api_secret: '',
  passphrase: '',
  symbols: ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'XRPUSDT'],
  timeframe: '15m',
  leverage: 5,
  interval: 60,
  rsi_period: 14,
  rsi_overbought: 70,
  rsi_oversold: 30,
  short_sma: 20,
  long_sma: 50,
  stop_loss_percent: 2.5,
  take_profit_percent: 5.5
});

// Derived Stores
export const openPositions = derived(
  positions,
  $positions => $positions.data.filter(p => p.status === 'open')
);

export const closedPositions = derived(
  positions,
  $positions => $positions.data.filter(p => p.status === 'closed')
);

export const totalProfitLoss = derived(
  closedPositions,
  $closedPositions => {
    return $closedPositions.reduce((total, pos) => total + parseFloat(pos.profit_loss || 0), 0);
  }
);

// Action Creators
export const fetchTradingStatus = async () => {
  tradingStatus.update(state => ({ ...state, loading: true, error: null }));
  
  try {
    const response = await tradingService.getStatus();
    if (response.success) {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        trading: response.data.trading,
        symbols: response.data.symbols,
        positions: response.data.positions,
        stats: response.data.stats
      }));
    } else {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to fetch trading status'
      }));
    }
  } catch (error) {
    tradingStatus.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
  }
};

export const startTrading = async (config) => {
  tradingStatus.update(state => ({ ...state, loading: true, error: null }));
  
  try {
    const response = await tradingService.startTrading(config);
    if (response.success) {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        trading: true
      }));
      return { success: true };
    } else {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to start trading'
      }));
      return { success: false, error: response.error };
    }
  } catch (error) {
    tradingStatus.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
    return { success: false, error: error.message };
  }
};

export const stopTrading = async () => {
  tradingStatus.update(state => ({ ...state, loading: true, error: null }));
  
  try {
    const response = await tradingService.stopTrading();
    if (response.success) {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        trading: false
      }));
      return { success: true };
    } else {
      tradingStatus.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to stop trading'
      }));
      return { success: false, error: response.error };
    }
  } catch (error) {
    tradingStatus.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
    return { success: false, error: error.message };
  }
};

export const fetchPositions = async (filters = {}) => {
  positions.update(state => ({ ...state, loading: true, error: null }));
  
  try {
    const response = await tradingService.getPositions(filters);
    if (response.success) {
      positions.update(state => ({
        ...state,
        loading: false,
        data: response.positions
      }));
    } else {
      positions.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to fetch positions'
      }));
    }
  } catch (error) {
    positions.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
  }
};

export const fetchMarketData = async (symbol, timeframe) => {
  marketData.update(state => ({ 
    ...state, 
    loading: true, 
    error: null,
    symbol: symbol || state.symbol,
    timeframe: timeframe || state.timeframe
  }));
  
  try {
    const response = await marketService.getMarketData(
      symbol || marketData.symbol,
      timeframe || marketData.timeframe
    );
    
    if (response.success) {
      marketData.update(state => ({
        ...state,
        loading: false,
        candles: response.data
      }));
    } else {
      marketData.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to fetch market data'
      }));
    }
  } catch (error) {
    marketData.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
  }
};

export const fetchSymbols = async () => {
  symbols.update(state => ({ ...state, loading: true, error: null }));
  
  try {
    const response = await marketService.getSymbols();
    if (response.success) {
      symbols.update(state => ({
        ...state,
        loading: false,
        data: response.symbols
      }));
    } else {
      symbols.update(state => ({
        ...state,
        loading: false,
        error: response.error || 'Failed to fetch symbols'
      }));
    }
  } catch (error) {
    symbols.update(state => ({
      ...state,
      loading: false,
      error: error.message || 'Unknown error occurred'
    }));
  }
};
