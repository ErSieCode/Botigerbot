<!-- src/routes/Positions.svelte -->
<script>
  import { onMount, onDestroy } from 'svelte';
  import { 
    positions, 
    openPositions,
    closedPositions,
    totalProfitLoss,
    fetchPositions
  } from '../stores/tradingStore';
  import { format } from 'date-fns';
  
  let activeTab = 'open';
  let refreshInterval;
  
  onMount(() => {
    // Initial fetch
    fetchPositions();
    
    // Set up auto refresh
    refreshInterval = setInterval(() => {
      fetchPositions();
    }, 15000);
  });
  
  onDestroy(() => {
    clearInterval(refreshInterval);
  });
  
  const formatDate = (dateStr) => {
    if (!dateStr) return '';
    return format(new Date(dateStr), 'MMM dd, yyyy HH:mm:ss');
  };
  
  const setTab = (tab) => {
    activeTab = tab;
  };
</script>

<div class="positions-container">
  <div class="positions-header">
    <h2>Trading Positions</h2>
    
    <div class="refresh-button" on:click={() => fetchPositions()}>
      <svg viewBox="0 0 24 24" width="18" height="18">
        <path fill="currentColor" d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z" />
      </svg>
      <span>Refresh</span>
    </div>
  </div>
  
  <div class="positions-tabs">
    <button 
      class={activeTab === 'open' ? 'active' : ''} 
      on:click={() => setTab('open')}
    >
      Open Positions ({$openPositions.length})
    </button>
    <button 
      class={activeTab === 'closed' ? 'active' : ''} 
      on:click={() => setTab('closed')}
    >
      Closed Positions ({$closedPositions.length})
    </button>
  </div>
  
  {#if $positions.loading}
    <div class="loading-container">
      <div class="spinner"></div>
      <p>Loading positions...</p>
    </div>
  {:else if $positions.error}
    <div class="error-container">
      <p>Error loading positions: {$positions.error}</p>
      <button on:click={() => fetchPositions()}>Try Again</button>
    </div>
  {:else}
    {#if activeTab === 'open'}
      {#if $openPositions.length === 0}
        <div class="empty-positions">
          <p>No open positions</p>
          <small>When trades are opened, they will appear here.</small>
        </div>
      {:else}
        <div class="positions-table-container">
          <table class="positions-table">
            <thead>
              <tr>
                <th>Symbol</th>
                <th>Type</th>
                <th>Entry Price</th>
                <th>Position Size</th>
                <th>Leverage</th>
                <th>Open Date</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {#each $openPositions as position}
                <tr>
                  <td class="symbol-cell">
                    <strong>{position.symbol}</strong>
                  </td>
                  <td class="position-type {position.position_type}">
                    {position.position_type === 'long' ? 'LONG' : 'SHORT'}
                  </td>
                  <td class="number-cell">{parseFloat(position.entry_price).toFixed(4)}</td>
                  <td class="number-cell">{parseFloat(position.position_size).toFixed(4)}</td>
                  <td class="number-cell">{position.leverage}x</td>
                  <td>{formatDate(position.inserted_at)}</td>
                  <td>
                    <span class="status open">Open</span>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
    {:else if activeTab === 'closed'}
      {#if $closedPositions.length === 0}
        <div class="empty-positions">
          <p>No closed positions</p>
          <small>When trades are closed, they will appear here.</small>
        </div>
      {:else}
        <div class="summary-card">
          <div class="summary-item">
            <span class="summary-label">Total Positions:</span>
            <span class="summary-value">{$closedPositions.length}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total Profit/Loss:</span>
            <span class="summary-value {$totalProfitLoss >= 0 ? 'profit' : 'loss'}">
              {$totalProfitLoss.toFixed(2)}%
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Profitable Trades:</span>
            <span class="summary-value profit">
              {$closedPositions.filter(p => parseFloat(p.profit_loss_percent) > 0).length}
              ({(($closedPositions.filter(p => parseFloat(p.profit_loss_percent) > 0).length / $closedPositions.length) * 100).toFixed(1)}%)
            </span>
          </div>
        </div>
        
        <div class="positions-table-container">
          <table class="positions-table">
            <thead>
              <tr>
                <th>Symbol</th>
                <th>Type</th>
                <th>Entry Price</th>
                <th>Exit Price</th>
                <th>Position Size</th>
                <th>P/L</th>
                <th>P/L %</th>
                <th>Open Date</th>
                <th>Close Date</th>
              </tr>
            </thead>
            <tbody>
              {#each $closedPositions as position}
                <tr>
                  <td class="symbol-cell">
                    <strong>{position.symbol}</strong>
                  </td>
                  <td class="position-type {position.position_type}">
                    {position.position_type === 'long' ? 'LONG' : 'SHORT'}
                  </td>
                  <td class="number-cell">{parseFloat(position.entry_price).toFixed(4)}</td>
                  <td class="number-cell">{parseFloat(position.exit_price).toFixed(4)}</td>
                  <td class="number-cell">{parseFloat(position.position_size).toFixed(4)}</td>
                  <td class="number-cell {parseFloat(position.profit_loss) >= 0 ? 'profit' : 'loss'}">
                    {parseFloat(position.profit_loss).toFixed(4)}
                  </td>
                  <td class="number-cell {parseFloat(position.profit_loss_percent) >= 0 ? 'profit' : 'loss'}">
                    {parseFloat(position.profit_loss_percent).toFixed(2)}%
                  </td>
                  <td>{formatDate(position.inserted_at)}</td>
                  <td>{formatDate(position.closed_at)}</td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
    {/if}
  {/if}
</div>

<style>
  .positions-container {
    width: 100%;
  }
  
  .positions-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1.5rem;
  }
  
  .positions-header h2 {
    margin: 0;
    font-weight: 600;
    font-size: 1.5rem;
    color: #1a202c;
  }
  
  .refresh-button {
    display: flex;
    align-items: center;
    background-color: #ebf8ff;
    color: #3182ce;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .refresh-button:hover {
    background-color: #bee3f8;
  }
  
  .refresh-button svg {
    margin-right: 0.5rem;
  }
  
  .positions-tabs {
    display: flex;
    margin-bottom: 1.5rem;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .positions-tabs button {
    padding: 0.75rem 1.5rem;
    background: none;
    border: none;
    border-bottom: 2px solid transparent;
    font-weight: 500;
    color: #4a5568;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .positions-tabs button:hover {
    color: #3182ce;
  }
  
  .positions-tabs button.active {
    color: #3182ce;
    border-bottom-color: #3182ce;
  }
  
  .loading-container,
  .error-container,
  .empty-positions {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    padding: 3rem;
    text-align: center;
  }
  
  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  
  .loading-container .spinner {
    width: 2rem;
    height: 2rem;
    border: 3px solid rgba(66, 153, 225, 0.3);
    border-top-color: #3182ce;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 1rem;
  }
  
  .error-container {
    color: #c53030;
  }
  
  .error-container button {
    margin-top: 1rem;
    padding: 0.5rem 1rem;
    background-color: #f56565;
    color: white;
    border: none;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
  }
  
  .empty-positions p {
    font-size: 1.125rem;
    color: #4a5568;
    margin-bottom: 0.5rem;
  }
  
  .empty-positions small {
    color: #718096;
  }
  
  .summary-card {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    display: flex;
    justify-content: space-between;
  }
  
  .summary-item {
    display: flex;
    flex-direction: column;
  }
  
  .summary-label {
    font-size: 0.875rem;
    color: #718096;
    margin-bottom: 0.25rem;
  }
  
  .summary-value {
    font-size: 1.25rem;
    font-weight: 600;
    color: #2d3748;
  }
  
  .summary-value.profit {
    color: #38a169;
  }
  
  .summary-value.loss {
    color: #e53e3e;
  }
  
  .positions-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    overflow-x: auto;
  }
  
  .positions-table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .positions-table th {
    text-align: left;
    padding: 1rem;
    font-size: 0.875rem;
    font-weight: 600;
    color: #4a5568;
    background-color: #f7fafc;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .positions-table td {
    padding: 1rem;
    font-size: 0.875rem;
    color: #4a5568;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .positions-table tr:hover {
    background-color: #f7fafc;
  }
  
  .symbol-cell {
    color: #2d3748;
  }
  
  .number-cell {
    text-align: right;
    font-family: monospace;
  }
  
  .position-type {
    font-weight: 600;
  }
  
  .position-type.long {
    color: #38a169;
  }
  
  .position-type.short {
    color: #e53e3e;
  }
  
  .profit {
    color: #38a169;
  }
  
  .loss {
    color: #e53e3e;
  }
  
  .status {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 600;
  }
  
  .status.open {
    background-color: #c6f6d5;
    color: #2f855a;
  }
  
  .status.closed {
    background-color: #e2e8f0;
    color: #4a5568;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  @media (max-width: 768px) {
    .positions-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .refresh-button {
      margin-top: 1rem;
    }
    
    .summary-card {
      flex-direction: column;
    }
    
    .summary-item {
      margin-bottom: 1rem;
    }
  }
</style>
