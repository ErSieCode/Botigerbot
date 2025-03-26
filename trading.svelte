<!-- src/routes/Trading.svelte -->
<script>
  import { onMount } from 'svelte';
  import { 
    tradingStatus, 
    tradingForm, 
    symbols,
    fetchSymbols,
    startTrading, 
    stopTrading 
  } from '../stores/tradingStore';
  import { getNotificationsContext } from 'svelte-notifications';
  
  const { addNotification } = getNotificationsContext();
  
  // Local state for form validation
  let errors = {};
  let saving = false;
  let selectedSymbols = [];
  
  onMount(() => {
    fetchSymbols();
  });
  
  $: {
    // Update selected symbols when form changes
    selectedSymbols = $tradingForm.symbols;
  }
  
  const validateForm = () => {
    errors = {};
    
    // Check required fields
    if (!$tradingForm.api_key) {
      errors.api_key = 'API Key is required';
    }
    
    if (!$tradingForm.api_secret) {
      errors.api_secret = 'API Secret is required';
    }
    
    if (!$tradingForm.passphrase) {
      errors.passphrase = 'API Passphrase is required';
    }
    
    if (!$tradingForm.symbols || $tradingForm.symbols.length === 0) {
      errors.symbols = 'At least one symbol must be selected';
    }
    
    // Numeric validations
    if ($tradingForm.leverage <= 0 || $tradingForm.leverage > 100) {
      errors.leverage = 'Leverage must be between 1 and 100';
    }
    
    if ($tradingForm.rsi_period < 1 || $tradingForm.rsi_period > 50) {
      errors.rsi_period = 'RSI Period must be between 1 and 50';
    }
    
    if ($tradingForm.rsi_overbought <= $tradingForm.rsi_oversold) {
      errors.rsi_overbought = 'RSI Overbought must be greater than Oversold level';
    }
    
    if ($tradingForm.short_sma >= $tradingForm.long_sma) {
      errors.short_sma = 'Short SMA period must be less than Long SMA period';
    }
    
    if ($tradingForm.stop_loss_percent <= 0 || $tradingForm.stop_loss_percent > 50) {
      errors.stop_loss_percent = 'Stop Loss must be between 0.1 and 50 percent';
    }
    
    if ($tradingForm.take_profit_percent <= 0 || $tradingForm.take_profit_percent > 100) {
      errors.take_profit_percent = 'Take Profit must be between 0.1 and 100 percent';
    }
    
    return Object.keys(errors).length === 0;
  };
  
  const handleSubmit = async () => {
    if (!validateForm()) {
      addNotification({
        text: 'Please fix the errors in the form',
        type: 'danger',
        position: 'top-right',
        removeAfter: 5000
      });
      return;
    }
    
    saving = true;
    
    // Convert values to proper format
    const config = {
      api_key: $tradingForm.api_key,
      api_secret: $tradingForm.api_secret,
      passphrase: $tradingForm.passphrase,
      symbols: $tradingForm.symbols,
      timeframe: $tradingForm.timeframe,
      leverage: Number($tradingForm.leverage),
      interval: Number($tradingForm.interval) * 1000, // Convert to milliseconds
      strategy: {
        rsi_period: Number($tradingForm.rsi_period),
        rsi_overbought: Number($tradingForm.rsi_overbought),
        rsi_oversold: Number($tradingForm.rsi_oversold),
        short_sma: Number($tradingForm.short_sma),
        long_sma: Number($tradingForm.long_sma),
        stop_loss_percent: Number($tradingForm.stop_loss_percent),
        take_profit_percent: Number($tradingForm.take_profit_percent)
      }
    };
    
    const result = await startTrading(config);
    
    saving = false;
    
    if (result.success) {
      addNotification({
        text: 'Trading started successfully',
        type: 'success',
        position: 'top-right',
        removeAfter: 3000
      });
    } else {
      addNotification({
        text: `Failed to start trading: ${result.error}`,
        type: 'danger',
        position: 'top-right',
        removeAfter: 5000
      });
    }
  };
  
  const handleStop = async () => {
    saving = true;
    
    const result = await stopTrading();
    
    saving = false;
    
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
        removeAfter: 5000
      });
    }
  };
  
  const toggleSymbol = (symbolId) => {
    const index = selectedSymbols.indexOf(symbolId);
    
    if (index === -1) {
      // Add symbol
      selectedSymbols = [...selectedSymbols, symbolId];
    } else {
      // Remove symbol
      selectedSymbols = [...selectedSymbols.slice(0, index), ...selectedSymbols.slice(index + 1)];
    }
    
    // Update store
    tradingForm.update(form => ({
      ...form,
      symbols: selectedSymbols
    }));
  };
</script>

<div class="trading-container">
  <div class="trading-header">
    <h2>Trading Configuration</h2>
    
    <div class="trading-status">
      <span class="status-label">Status:</span>
      <span class="status-value {$tradingStatus.trading ? 'status-active' : 'status-inactive'}">
        {$tradingStatus.trading ? 'Active' : 'Inactive'}
      </span>
      
      {#if $tradingStatus.trading}
        <button 
          class="status-toggle stop" 
          on:click={handleStop}
          disabled={saving}
        >
          {#if saving}
            <div class="spinner"></div>
            <span>Processing...</span>
          {:else}
            <span>Stop Trading</span>
          {/if}
        </button>
      {/if}
    </div>
  </div>
  
  <div class="trading-form-container">
    <form on:submit|preventDefault={handleSubmit} class="trading-form">
      <div class="form-section">
        <h3>API Configuration</h3>
        
        <div class="form-row">
          <div class="form-group">
            <label for="api_key">API Key</label>
            <input 
              type="text" 
              id="api_key" 
              bind:value={$tradingForm.api_key} 
              class={errors.api_key ? 'error' : ''}
            />
            {#if errors.api_key}
              <span class="error-message">{errors.api_key}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="api_secret">API Secret</label>
            <input 
              type="password" 
              id="api_secret" 
              bind:value={$tradingForm.api_secret}
              class={errors.api_secret ? 'error' : ''}
            />
            {#if errors.api_secret}
              <span class="error-message">{errors.api_secret}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="passphrase">API Passphrase</label>
            <input 
              type="password" 
              id="passphrase" 
              bind:value={$tradingForm.passphrase}
              class={errors.passphrase ? 'error' : ''}
            />
            {#if errors.passphrase}
              <span class="error-message">{errors.passphrase}</span>
            {/if}
          </div>
        </div>
      </div>
      
      <div class="form-section">
        <h3>Trading Parameters</h3>
        
        <div class="form-row">
          <div class="form-group">
            <label for="timeframe">Timeframe</label>
            <select id="timeframe" bind:value={$tradingForm.timeframe}>
              <option value="1m">1 Minute</option>
              <option value="5m">5 Minutes</option>
              <option value="15m">15 Minutes</option>
              <option value="30m">30 Minutes</option>
              <option value="1h">1 Hour</option>
              <option value="4h">4 Hours</option>
              <option value="1d">1 Day</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="leverage">Leverage</label>
            <input 
              type="number" 
              id="leverage" 
              bind:value={$tradingForm.leverage}
              min="1"
              max="100" 
              class={errors.leverage ? 'error' : ''}
            />
            {#if errors.leverage}
              <span class="error-message">{errors.leverage}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="interval">Update Interval (seconds)</label>
            <input 
              type="number" 
              id="interval" 
              bind:value={$tradingForm.interval}
              min="10"
              max="3600"
            />
          </div>
        </div>
      </div>
      
      <div class="form-section">
        <h3>Trading Symbols</h3>
        
        {#if errors.symbols}
          <span class="error-message block-error">{errors.symbols}</span>
        {/if}
        
        <div class="symbols-grid">
          {#if $symbols.loading}
            <div class="loading-symbols">Loading symbols...</div>
          {:else if $symbols.error}
            <div class="error-symbols">Failed to load symbols: {$symbols.error}</div>
          {:else}
            {#each $symbols.data as symbol}
              <div 
                class="symbol-card {selectedSymbols.includes(symbol.id) ? 'selected' : ''}" 
                on:click={() => toggleSymbol(symbol.id)}
              >
                <div class="symbol-name">{symbol.name}</div>
                <div class="symbol-id">{symbol.id}</div>
                <div class="symbol-pair">{symbol.base}/{symbol.quote}</div>
              </div>
            {/each}
          {/if}
        </div>
      </div>
      
      <div class="form-section">
        <h3>Strategy Configuration</h3>
        
        <div class="form-row">
          <div class="form-group">
            <label for="rsi_period">RSI Period</label>
            <input 
              type="number" 
              id="rsi_period" 
              bind:value={$tradingForm.rsi_period}
              min="1"
              max="50" 
              class={errors.rsi_period ? 'error' : ''}
            />
            {#if errors.rsi_period}
              <span class="error-message">{errors.rsi_period}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="rsi_overbought">RSI Overbought Level</label>
            <input 
              type="number" 
              id="rsi_overbought" 
              bind:value={$tradingForm.rsi_overbought}
              min="50"
              max="100" 
              class={errors.rsi_overbought ? 'error' : ''}
            />
            {#if errors.rsi_overbought}
              <span class="error-message">{errors.rsi_overbought}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="rsi_oversold">RSI Oversold Level</label>
            <input 
              type="number" 
              id="rsi_oversold" 
              bind:value={$tradingForm.rsi_oversold}
              min="0"
              max="50" 
              class={errors.rsi_oversold ? 'error' : ''}
            />
            {#if errors.rsi_oversold}
              <span class="error-message">{errors.rsi_oversold}</span>
            {/if}
          </div>
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label for="short_sma">Short SMA Period</label>
            <input 
              type="number" 
              id="short_sma" 
              bind:value={$tradingForm.short_sma}
              min="1"
              max="100" 
              class={errors.short_sma ? 'error' : ''}
            />
            {#if errors.short_sma}
              <span class="error-message">{errors.short_sma}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="long_sma">Long SMA Period</label>
            <input 
              type="number" 
              id="long_sma" 
              bind:value={$tradingForm.long_sma}
              min="1"
              max="200" 
              class={errors.long_sma ? 'error' : ''}
            />
            {#if errors.long_sma}
              <span class="error-message">{errors.long_sma}</span>
            {/if}
          </div>
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label for="stop_loss_percent">Stop Loss (%)</label>
            <input 
              type="number" 
              id="stop_loss_percent" 
              bind:value={$tradingForm.stop_loss_percent}
              min="0.1"
              max="50"
              step="0.1" 
              class={errors.stop_loss_percent ? 'error' : ''}
            />
            {#if errors.stop_loss_percent}
              <span class="error-message">{errors.stop_loss_percent}</span>
            {/if}
          </div>
          
          <div class="form-group">
            <label for="take_profit_percent">Take Profit (%)</label>
            <input 
              type="number" 
              id="take_profit_percent" 
              bind:value={$tradingForm.take_profit_percent}
              min="0.1"
              max="100"
              step="0.1" 
              class={errors.take_profit_percent ? 'error' : ''}
            />
            {#if errors.take_profit_percent}
              <span class="error-message">{errors.take_profit_percent}</span>
            {/if}
          </div>
        </div>
      </div>
      
      <div class="form-actions">
        <button 
          type="submit" 
          class="submit-button {$tradingStatus.trading ? 'disabled' : ''}"
          disabled={$tradingStatus.trading || saving}
        >
          {#if saving}
            <div class="spinner"></div>
            <span>Processing...</span>
          {:else}
            <span>Start Trading</span>
          {/if}
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  .trading-container {
    width: 100%;
  }
  
  .trading-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1.5rem;
  }
  
  .trading-header h2 {
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
  
  .trading-form-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    overflow: hidden;
  }
  
  .trading-form {
    padding: 1.5rem;
  }
  
  .form-section {
    margin-bottom: 2rem;
  }
  
  .form-section h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    font-size: 1.25rem;
    font-weight: 500;
    color: #2d3748;
    border-bottom: 1px solid #e2e8f0;
    padding-bottom: 0.5rem;
  }
  
  .form-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1.5rem;
    margin-bottom: 1rem;
  }
  
  .form-group {
    margin-bottom: 1rem;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: #4a5568;
  }
  
  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 1rem;
    transition: all 0.2s ease;
  }
  
  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #4299e1;
    box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.2);
  }
  
  .form-group input.error,
  .form-group select.error {
    border-color: #f56565;
  }
  
  .error-message {
    display: block;
    font-size: 0.75rem;
    color: #e53e3e;
    margin-top: 0.25rem;
  }
  
  .block-error {
    margin-bottom: 1rem;
  }
  
  .symbols-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .symbol-card {
    background-color: #f7fafc;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    padding: 1rem;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .symbol-card:hover {
    border-color: #4299e1;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }
  
  .symbol-card.selected {
    border-color: #4299e1;
    background-color: #ebf8ff;
  }
  
  .symbol-name {
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 0.25rem;
  }
  
  .symbol-id {
    font-size: 0.875rem;
    color: #4a5568;
    margin-bottom: 0.25rem;
  }
  
  .symbol-pair {
    font-size: 0.75rem;
    color: #718096;
  }
  
  .loading-symbols,
  .error-symbols {
    grid-column: span 4;
    padding: 2rem;
    text-align: center;
    color: #718096;
    font-size: 0.875rem;
  }
  
  .form-actions {
    margin-top: 2rem;
    display: flex;
    justify-content: flex-end;
  }
  
  .submit-button {
    padding: 0.75rem 1.5rem;
    background-color: #4299e1;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
  }
  
  .submit-button:hover {
    background-color: #3182ce;
  }
  
  .submit-button.disabled {
    background-color: #a0aec0;
    cursor: not-allowed;
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
    .form-row {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .symbols-grid {
      grid-template-columns: repeat(3, 1fr);
    }
  }
  
  @media (max-width: 768px) {
    .trading-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .trading-status {
      margin-top: 1rem;
    }
    
    .form-row {
      grid-template-columns: 1fr;
    }
    
    .symbols-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }
  
  @media (max-width: 480px) {
    .symbols-grid {
      grid-template-columns: 1fr;
    }
  }
</style>
