<!-- src/routes/Dashboard.svelte -->
<script>
  import { onMount, onDestroy } from 'svelte';
  import { 
    tradingStatus, 
    positions, 
    openPositions,
    closedPositions,
    totalProfitLoss,
    fetchTradingStatus, 
    fetchPositions, 
    startTrading, 
    stopTrading 
  } from '../stores/tradingStore';
  import ApexChart from 'svelte-apexcharts';
  import { getNotificationsContext } from 'svelte-notifications';
  import { format } from 'date-fns';
  
  const { addNotification } = getNotificationsContext();
  
  let statusInterval;
  let positionsInterval;
  
  onMount(() => {
    // Initial data fetch
    fetchTradingStatus();
    fetchPositions();
    
    // Set up periodic refresh
    statusInterval = setInterval(fetchTradingStatus, 10000);
    positionsInterval = setInterval(fetchPositions, 15000);
  });
  
  onDestroy(() => {
    // Clear intervals when component is destroyed
    clearInterval(statusInterval);
    clearInterval(positionsInterval);
  });
  
  // Chart options for profit/loss
  let profitLossOptions = {
    chart: {
      type: 'bar',
      height: 250,
      toolbar: {
        show: false
      }
    },
    plotOptions: {
      bar: {
        borderRadius: 4,
        horizontal: false,
        columnWidth: '70%',
      }
    },
    dataLabels: {
      enabled: false,
    },
    xaxis: {
      categories: [],
      axisBorder: {
        show: false,
      },
      axisTicks: {
        show: false,
      },
    },
    colors: ['#38a169', '#e53e3e'],
    fill: {
      opacity: 1,
    },
    tooltip: {
      y: {
        formatter: function(val) {
          return val + '%';
        }
      }
    }
  };
  
  // Chart series for profit/loss
  $: profitLossSeries = [
    {
      name: 'Profit/Loss %',
      data: $closedPositions.slice(-10).map(p => p.profit_loss_percent)
    }
  ];
  
  // Chart options for assets distribution
  let assetsOptions = {
    chart: {
      type: 'donut',
      height: 250
    },
    legend: {
      position: 'bottom'
    },
    dataLabels: {
      enabled: true,
    },
    colors: ['#3182ce', '#38a169', '#e53e3e', '#ecc94b', '#805ad5'],
    responsive: [{
      breakpoint: 480,
      options: {
        chart: {
          width: 200
        },
        legend: {
          position: 'bottom'
        }
      }
    }]
  };
  
  // Function to toggle trading state
  const toggleTrading = async () => {
    if ($tradingStatus.trading) {
      const result = await stopTrading();
      if (result.success) {
        addNotification({
          text: 'Trading stopped successfully',
          type: 'success',
          position: 'top-right',
          removeAfter: 3000
        });
      } else {
        addNotification({
          text: `Failed to stop trading: ${result.error}`,
          type: 'danger',
          position: 'top-right',
          removeAfter: 3000
        });
      }
    } else {
      addNotification({
        text: 'Please configure trading parameters in the Trading section.',
        type: 'info',
        position: 'top-right',
        removeAfter: 5000
      });
    }
  };
</script>

<div class="dashboard-container">
  <div class="dashboard-header">
    <h2>Trading Dashboard</h2>
    
    <div class="trading-status">
      <span class="status-label">Status:</span>
      <span class="status-value {$tradingStatus.trading ? 'status-active' : 'status-inactive'}">
        {$tradingStatus.trading ? 'Active' : 'Inactive'}
      </span>
      
      <button 
        class="status-toggle {$tradingStatus.trading ? 'stop' : 'start'}" 
        on:click={toggleTrading}
        disabled={$tradingStatus.loading}
      >
        {#if $tradingStatus.loading}
          <div class="spinner"></div>
          <span>Processing...</span>
        {:else}
          <span>{$tradingStatus.trading ? 'Stop Trading' : 'Start Trading'}</span>
        {/if}
      </button>
    </div>
  </div>
  
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-icon profit">
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M3,13H5.79L10.1,7.79L13.79,12.79L20,5V9H22V3H16V5H19.5L13.79,11.21L10.1,6.21L5,12H3V13Z" />
        </svg>
      </div>
      <div class="stat-content">
        <span class="stat-title">Total Profit/Loss</span>
        <span class="stat-value {$totalProfitLoss >= 0 ? 'profit' : 'loss'}">
          {$totalProfitLoss.toFixed(2)}%
        </span>
      </div>
    </div>
    
    <div class="stat-card">
      <div class="stat-icon active">
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M4,2H20A2,2 0 0,1 22,4V16A2,2 0 0,1 20,18H16L12,22L8,18H4A2,2 0 0,1 2,16V4A2,2 0 0,1 4,2M4,4V16H8.83L12,19.17L15.17,16H20V4H4M6,7H18V9H6V7M6,11H16V13H6V11Z" />
        </svg>
      </div>
      <div class="stat-content">
        <span class="stat-title">Open Positions</span>
        <span class="stat-value">{$openPositions.length}</span>
      </div>
    </div>
    
    <div class="stat-card">
      <div class="stat-icon inactive">
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M17,4H7A2,2 0 0,0 5,6V18A2,2 0 0,0 7,20H17A2,2 0 0,0 19,18V6A2,2 0 0,0 17,4M10,18H7V16H10V18M10,15H7V13H10V15M10,12H7V10H10V12M10,9H7V7H10V9M17,18H11V16H17V18M17,15H11V13H17V15M17,12H11V10H17V12M17,9H11V7H17V9Z" />
        </svg>
      </div>
      <div class="stat-content">
        <span class="stat-title">Closed Positions</span>
        <span class="stat-value">{$closedPositions.length}</span>
      </div>
    </div>
    
    <div class="stat-card">
      <div class="stat-icon symbol">
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12,20C7.59,20 4,16.41 4,12C4,7.59 7.59,4 12,4C16.41,4 20,7.59 20,12C20,16.41 16.41,20 12,20M10,13H8V15H10V13M11.5,7.5V8.5H9.5V7.5H11.5M13.5,7.5H15.5V8.5H13.5V7.5M9.5,12H11.5V13H9.5V12M13.5,12V13H15.5V12H13.5Z" />
        </svg>
      </div>
      <div class="stat-content">
        <span class="stat-title">Active Symbols</span>
        <span class="stat-value">{$tradingStatus.symbols?.length || 0}</span>
      </div>
    </div>
  </div>
  
  <div class="charts-grid">
    <div class="chart-card">
      <h3>Recent Trades Performance</h3>
      
      {#if $closedPositions.length > 0}
        <ApexChart
          options={profitLossOptions}
          series={profitLossSeries}
          type="bar"
          height={250}
        />
      {:else}
        <div class="empty-chart">
          <p>No closed positions yet</p>
        </div>
      {/if}
    </div>
    
    <div class="chart-card">
      <h3>Open Positions</h3>
      
      {#if $openPositions.length > 0}
        <div class="positions-table">
          <table>
            <thead>
              <tr>
                <th>Symbol</th>
                <th>Type</th>
                <th>Entry Price</th>
                <th>Size</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {#each $openPositions as position}
                <tr>
                  <td><strong>{position.symbol}</strong></td>
                  <td class="{position.position_type === 'long' ? 'type-long' : 'type-short'}">
                    {position.position_type === 'long' ? 'LONG' : 'SHORT'}
                  </td>
                  <td>{parseFloat(position.entry_price).toFixed(4)}</td>
                  <td>{parseFloat(position.position_size).toFixed(4)}</td>
                  <td>{format(new Date(position.inserted_at), 'MMM dd, HH:mm')}</td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {:else}
        <div class="empty-chart">
          <p>No open positions</p>
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  .dashboard-container {
    width: 100%;
  }
  
  .dashboard-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1.5rem;
  }
  
  .dashboard-header h2 {
    margin: 0;
    font-weight: 600;
    font-size: 1.5rem;
    color: #1a202c;
  }
  
  .trading-status {
    display: flex;
    align-items: center;
  }
  
  .status-label {
    margin-right: 0.5rem;
    font-weight: 500;
    color: #4a5568;
  }
  
  .status-value {
    font-weight: 600;
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    margin-right: 1rem;
  }
  
  .status-active {
    background-color: #c6f6d5;
    color: #2f855a;
  }
  
  .status-inactive {
    background-color: #fed7d7;
    color: #c53030;
  }
  
  .status-toggle {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    transition: all 0.2s ease;
  }
  
  .status-toggle.start {
    background-color: #48bb78;
    color: white;
  }
  
  .status-toggle.start:hover {
    background-color: #38a169;
  }
  
  .status-toggle.stop {
    background-color: #f56565;
    color: white;
  }
  
  .status-toggle.stop:hover {
    background-color: #e53e3e;
  }
  
  .status-toggle:disabled {
    background-color: #a0aec0;
    cursor: not-allowed;
  }
  
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1.5rem;
    margin-bottom: 1.5rem;
  }
  
  .stat-card {
    background-color: white;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    display: flex;
    align-items: center;
  }
  
  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 1rem;
  }
  
  .stat-icon.profit {
    background-color: #c6f6d5;
    color: #2f855a;
  }
  
  .stat-icon.active {
    background-color: #bee3f8;
    color: #2c5282;
  }
  
  .stat-icon.inactive {
    background-color: #e2e8f0;
    color: #4a5568;
  }
  
  .stat-icon.symbol {
    background-color: #feebc8;
    color: #c05621;
  }
  
  .stat-content {
    display: flex;
    flex-direction: column;
  }
  
  .stat-title {
    font-size: 0.875rem;
    color: #718096;
    margin-bottom: 0.25rem;
  }
  
  .stat-value {
    font-size: 1.5rem;
    font-weight: 600;
    color: #1a202c;
  }
  
  .stat-value.profit {
    color: #2f855a;
  }
  
  .stat-value.loss {
    color: #c53030;
  }
  
  .charts-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }
  
  .chart-card {
    background-color: white;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }
  
  .chart-card h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    font-size: 1.25rem;
    font-weight: 500;
    color: #2d3748;
  }
  
  .empty-chart {
    height: 250px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #a0aec0;
    font-size: 1rem;
    border: 2px dashed #e2e8f0;
    border-radius: 4px;
  }
  
  .positions-table {
    width: 100%;
    overflow-x: auto;
  }
  
  .positions-table table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .positions-table th {
    text-align: left;
    padding: 0.75rem;
    border-bottom: 2px solid #e2e8f0;
    font-size: 0.875rem;
    font-weight: 600;
    color: #4a5568;
  }
  
  .positions-table td {
    padding: 0.75rem;
    border-bottom: 1px solid #e2e8f0;
    font-size: 0.875rem;
    color: #4a5568;
  }
  
  .positions-table .type-long {
    color: #38a169;
    font-weight: 600;
  }
  
  .positions-table .type-short {
    color: #e53e3e;
    font-weight: 600;
  }
  
  .spinner {
    width: 1rem;
    height: 1rem;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-right: 0.5rem;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  @media (max-width: 1024px) {
    .stats-grid {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .charts-grid {
      grid-template-columns: 1fr;
    }
  }
  
  @media (max-width: 640px) {
    .dashboard-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .trading-status {
      margin-top: 1rem;
    }
    
    .stats-grid {
      grid-template-columns: 1fr;
    }
  }
</style>
