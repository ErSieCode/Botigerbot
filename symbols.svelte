<!-- src/routes/Symbols.svelte -->
<script>
  import { onMount, onDestroy } from 'svelte';
  import { 
    marketData,
    symbols,
    fetchMarketData,
    fetchSymbols
  } from '../stores/tradingStore';
  import ApexChart from 'svelte-apexcharts';
  
  let selectedSymbol = 'BTCUSDT';
  let selectedTimeframe = '15m';
  let dataInterval;
  
  // Chart data and options
  let candlestickOptions = {
    chart: {
      type: 'candlestick',
      height: 500,
      toolbar: {
        show: true,
        tools: {
          download: true,
          selection: true,
          zoom: true,
          zoomin: true,
          zoomout: true,
          pan: true,
          reset: true
        }
      }
    },
    title: {
      text: 'Market Price Chart',
      align: 'left'
    },
    xaxis: {
      type: 'datetime',
      labels: {
        datetimeUTC: false
      }
    },
    yaxis: {
      tooltip: {
        enabled: true
      }
    },
    grid: {
      padding: {
        right: 30
      }
    },
    plotOptions: {
      candlestick: {
        colors: {
          upward: '#3DBAA2',
          downward: '#FF6B6B'
        }
      }
    }
  };
  
  // Volume chart options
  let volumeOptions = {
    chart: {
      type: 'bar',
      height: 160,
      brush: {
        enabled: true,
        target: 'candles'
      },
      selection: {
        enabled: true,
        xaxis: {},
        fill: {
          color: '#ccc',
          opacity: 0.4
        },
        stroke: {
          color: '#0D47A1',
        }
      },
    },
    dataLabels: {
      enabled: false
    },
    plotOptions: {
      bar: {
        columnWidth: '80%',
        colors: {
          ranges: [{
            from: -1000,
            to: 0,
            color: '#FF6B6B'
          }, {
            from: 1,
            to: 10000,
            color: '#3DBAA2'
          }]
        },
      }
    },
    stroke: {
      width: 0
    },
    xaxis: {
      type: 'datetime',
      axisBorder: { show: false },
      axisTicks: { show: false },
      labels: { show: false }
    },
    yaxis: {
      labels: {
        show: true,
        formatter: (value) => {
          return (value / 1000).toFixed(0) + 'K';
        }
      }
    },
    grid: {
      padding: {
        right: 30
      }
    }
  };
  
  // Prepare candlestick data for chart
  $: candleSeries = [{
    name: 'Candles',
    id: 'candles',
    data: $marketData.candles.map(candle => ({
      x: new Date(candle.timestamp),
      y: [
        candle.open,
        candle.high,
        candle.low,
        candle.close
      ]
    }))
  }];
  
  // Prepare volume data for chart
  $: volumeSeries = [{
    name: 'Volume',
    data: $marketData.candles.map(candle => ({
      x: new Date(candle.timestamp),
      y: candle.volume,
      color: candle.close > candle.open ? '#3DBAA2' : '#FF6B6B'
    }))
  }];
  
  // Handle symbol change
  const handleSymbolChange = (symbol) => {
    selectedSymbol = symbol;
    fetchMarketData(symbol, selectedTimeframe);
  };
  
  // Handle timeframe change
  const handleTimeframeChange = (e) => {
    selectedTimeframe = e.target.value;
    fetchMarketData(selectedSymbol, selectedTimeframe);
  };
  
  // Format large numbers
  const formatNumber = (num) => {
    if (num >= 1000000000) {
      return (num / 1000000000).toFixed(2) + 'B';
    }
    if (num >= 1000000) {
      return (num / 1000000).toFixed(2) + 'M';
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(2) + 'K';
    }
    return num.toFixed(2);
  };
  
  // Calculate price change
  const calculateChange = (candles) => {
    if (!candles || candles.length < 2) return { value: 0, percent: 0 };
    
    const latest = candles[candles.length - 1];
    const first = candles[0];
    
    const change = latest.close - first.open;
    const percentChange = (change / first.open) * 100;
    
    return {
      value: change,
      percent: percentChange
    };
  };
  
  // Get latest price
  $: latestPrice = $marketData.candles.length > 0 
    ? $marketData.candles[$marketData.candles.length - 1].close 
    : 0;
  
  // Calculate price change
  $: priceChange = calculateChange($marketData.candles);
  
  // Set up auto refresh
  onMount(() => {
    fetchSymbols();
    fetchMarketData(selectedSymbol, selectedTimeframe);
    
    dataInterval = setInterval(() => {
      fetchMarketData(selectedSymbol, selectedTimeframe);
    }, 30000); // Refresh every 30 seconds
  });
  
  onDestroy(() => {
    clearInterval(dataInterval);
  });
</script>

<div class="symbols-container">
  <div class="symbols-header">
    <h2>Market Data</h2>
    
    <div class="timeframe-selector">
      <label for="timeframe">Timeframe:</label>
      <select id="timeframe" value={selectedTimeframe} on:change={handleTimeframeChange}>
        <option value="1m">1 Minute</option>
        <option value="5m">5 Minutes</option>
        <option value="15m">15 Minutes</option>
        <option value="30m">30 Minutes</option>
        <option value="1h">1 Hour</option>
        <option value="4h">4 Hours</option>
        <option value="1d">1 Day</option>
      </select>
    </div>
  </div>
  
  <div class="symbols-content">
    <div class="symbols-sidebar">
      <div class="search-box">
        <input type="text" placeholder="Search symbol..." />
      </div>
      
      <div class="symbols-list">
        {#if $symbols.loading}
          <div class="symbols-loading">Loading symbols...</div>
        {:else if $symbols.error}
          <div class="symbols-error">Error loading symbols: {$symbols.error}</div>
        {:else}
          {#each $symbols.data as symbol}
            <div 
              class="symbol-item {selectedSymbol === symbol.id ? 'active' : ''}" 
              on:click={() => handleSymbolChange(symbol.id)}
            >
              <div class="symbol-info">
                <div class="symbol-name">{symbol.id}</div>
                <div class="symbol-base">{symbol.name}</div>
              </div>
            </div>
          {/each}
        {/if}
      </div>
    </div>
    
    <div class="symbol-details">
      {#if $marketData.loading}
        <div class="loading-chart">
          <div class="spinner"></div>
          <p>Loading market data...</p>
        </div>
      {:else if $marketData.error}
        <div class="error-chart">
          <p>Error loading market data: {$marketData.error}</p>
          <button on:click={() => fetchMarketData(selectedSymbol, selectedTimeframe)}>
            Try Again
          </button>
        </div>
      {:else if $marketData.candles.length === 0}
        <div class="empty-chart">
          <p>No data available for {selectedSymbol}</p>
        </div>
      {:else}
        <div class="symbol-header">
          <div class="symbol-title">
            <h3>{selectedSymbol}</h3>
            <div class="symbol-subtitle">
              {#each $symbols.data as symbol}
                {#if symbol.id === selectedSymbol}
                  {symbol.name} ({symbol.base}/{symbol.quote})
                {/if}
              {/each}
            </div>
          </div>
          
          <div class="symbol-price">
            <div class="current-price">${latestPrice.toFixed(4)}</div>
            <div class="price-change {priceChange.percent >= 0 ? 'positive' : 'negative'}">
              {priceChange.percent >= 0 ? '+' : ''}{priceChange.percent.toFixed(2)}%
            </div>
          </div>
        </div>
        
        <div class="chart-container">
          <div id="candlestick-chart">
            <ApexChart
              options={candlestickOptions}
              series={candleSeries}
              type="candlestick"
              height={500}
            />
          </div>
          
          <div id="volume-chart">
            <ApexChart
              options={volumeOptions}
              series={volumeSeries}
              type="bar"
              height={160}
            />
          </div>
        </div>
        
        <div class="market-stats">
          <div class="stats-card">
            <div class="stats-title">24h High</div>
            <div class="stats-value">
              ${Math.max(...$marketData.candles.map(c => c.high)).toFixed(4)}
            </div>
          </div>
          
          <div class="stats-card">
            <div class="stats-title">24h Low</div>
            <div class="stats-value">
              ${Math.min(...$marketData.candles.map(c => c.low)).toFixed(4)}
            </div>
          </div>
          
          <div class="stats-card">
            <div class="stats-title">24h Volume</div>
            <div class="stats-value">
              {formatNumber($marketData.candles.reduce((sum, c) => sum + c.volume, 0))}
            </div>
          </div>
          
          <div class="stats-card">
            <div class="stats-title">Price Change</div>
            <div class="stats-value {priceChange.percent >= 0 ? 'positive' : 'negative'}">
              {priceChange.percent >= 0 ? '+' : ''}{priceChange.percent.toFixed(2)}%
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  .symbols-container {
    width: 100%;
  }
  
  .symbols-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1.5rem;
  }
  
  .symbols-header h2 {
    margin: 0;
    font-weight: 600;
    font-size: 1.5rem;
    color: #1a202c;
  }
  
  .timeframe-selector {
    display: flex;
    align-items: center;
  }
  
  .timeframe-selector label {
    margin-right: 0.5rem;
    font-weight: 500;
    color: #4a5568;
  }
  
  .timeframe-selector select {
    padding: 0.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    background-color: white;
    font-size: 0.875rem;
  }
  
  .symbols-content {
    display: flex;
    gap: 1.5rem;
  }
  
  .symbols-sidebar {
    width: 240px;
    min-width: 240px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    max-height: 800px;
  }
  
  .search-box {
    padding: 1rem;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .search-box input {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 0.875rem;
  }
  
  .symbols-list {
    flex: 1;
    overflow-y: auto;
  }
  
  .symbols-loading,
  .symbols-error {
    padding: 1rem;
    color: #718096;
    font-size: 0.875rem;
    text-align: center;
  }
  
  .symbol-item {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #f7fafc;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .symbol-item:hover {
    background-color: #f7fafc;
  }
  
  .symbol-item.active {
    background-color: #ebf8ff;
    border-left: 3px solid #3182ce;
  }
  
  .symbol-info {
    display: flex;
    flex-direction: column;
  }
  
  .symbol-name {
    font-weight: 600;
    color: #2d3748;
  }
  
  .symbol-base {
    font-size: 0.75rem;
    color: #718096;
    margin-top: 0.25rem;
  }
  
  .symbol-details {
    flex: 1;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    padding: 1.5rem;
  }
  
  .loading-chart,
  .error-chart,
  .empty-chart {
    height: 500px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #718096;
  }
  
  .loading-chart .spinner {
    width: 2rem;
    height: 2rem;
    border: 3px solid rgba(66, 153, 225, 0.3);
    border-top-color: #3182ce;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 1rem;
  }
  
  .error-chart button {
    margin-top: 1rem;
    padding: 0.5rem 1rem;
    background-color: #4299e1;
    color: white;
    border: none;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
  }
  
  .symbol-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }
  
  .symbol-title h3 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 600;
    color: #2d3748;
  }
  
  .symbol-subtitle {
    font-size: 0.875rem;
    color: #718096;
    margin-top: 0.25rem;
  }
  
  .symbol-price {
    text-align: right;
  }
  
  .current-price {
    font-size: 1.5rem;
    font-weight: 600;
    color: #2d3748;
  }
  
  .price-change {
    margin-top: 0.25rem;
    font-weight: 500;
  }
  
  .price-change.positive {
    color: #38a169;
  }
  
  .price-change.negative {
    color: #e53e3e;
  }
  
  .chart-container {
    margin-bottom: 1.5rem;
  }
  
  .market-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1rem;
  }
  
  .stats-card {
    background-color: #f7fafc;
    padding: 1rem;
    border-radius: 4px;
  }
  
  .stats-title {
    font-size: 0.75rem;
    color: #718096;
    margin-bottom: 0.5rem;
  }
  
  .stats-value {
    font-size: 1.125rem;
    font-weight: 600;
    color: #2d3748;
  }
  
  .stats-value.positive {
    color: #38a169;
  }
  
  .stats-value.negative {
    color: #e53e3e;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  @media (max-width: 1024px) {
    .symbols-content {
      flex-direction: column;
    }
    
    .symbols-sidebar {
      width: 100%;
      min-width: 100%;
      max-height: 300px;
    }
    
    .market-stats {
      grid-template-columns: repeat(2, 1fr);
    }
  }
  
  @media (max-width: 640px) {
    .symbols-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .timeframe-selector {
      margin-top: 1rem;
    }
    
    .symbol-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .symbol-price {
      margin-top: 1rem;
      text-align: left;
    }
    
    .market-stats {
      grid-template-columns: 1fr;
    }
  }
</style>
