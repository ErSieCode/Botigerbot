<!-- src/routes/Settings.svelte -->
<script>
  import { onMount } from 'svelte';
  import { getNotificationsContext } from 'svelte-notifications';
  import { authService } from '../utils/api';
  
  const { addNotification } = getNotificationsContext();
  
  let user = null;
  let saving = false;
  
  // Theme settings
  let darkMode = false;
  let refreshInterval = 30;
  
  // Notification settings
  let emailNotifications = false;
  let tradeNotifications = true;
  let priceAlerts = false;
  
  // API settings (not stored in localStorage)
  let apiKey = '';
  let apiSecret = '';
  let apiPassphrase = '';
  
  onMount(() => {
    user = authService.getUser();
    
    // Load settings from localStorage
    const savedSettings = localStorage.getItem('user_settings');
    if (savedSettings) {
      const settings = JSON.parse(savedSettings);
      darkMode = settings.darkMode || false;
      refreshInterval = settings.refreshInterval || 30;
      emailNotifications = settings.emailNotifications || false;
      tradeNotifications = settings.tradeNotifications || true;
      priceAlerts = settings.priceAlerts || false;
    }
    
    // Apply dark mode if enabled
    if (darkMode) {
      document.body.classList.add('dark-mode');
    }
  });
  
  const saveSettings = () => {
    saving = true;
    
    setTimeout(() => {
      // Save settings to localStorage
      const settings = {
        darkMode,
        refreshInterval,
        emailNotifications,
        tradeNotifications,
        priceAlerts
      };
      
      localStorage.setItem('user_settings', JSON.stringify(settings));
      
      // Apply dark mode
      if (darkMode) {
        document.body.classList.add('dark-mode');
      } else {
        document.body.classList.remove('dark-mode');
      }
      
      // Show success notification
      addNotification({
        text: 'Settings saved successfully',
        type: 'success',
        position: 'top-right',
        removeAfter: 3000
      });
      
      saving = false;
    }, 500);
  };
  
  const saveApiSettings = () => {
    if (!apiKey || !apiSecret || !apiPassphrase) {
      addNotification({
        text: 'All API fields are required',
        type: 'warning',
        position: 'top-right',
        removeAfter: 3000
      });
      return;
    }
    
    saving = true;
    
    setTimeout(() => {
      // In a real app, these would be saved to the server securely
      // For the demo, just show success
      
      addNotification({
        text: 'API settings saved successfully',
        type: 'success',
        position: 'top-right',
        removeAfter: 3000
      });
      
      // Clear fields for security
      apiKey = '';
      apiSecret = '';
      apiPassphrase = '';
      
      saving = false;
    }, 500);
  };
  
  const resetSettings = () => {
    darkMode = false;
    refreshInterval = 30;
    emailNotifications = false;
    tradeNotifications = true;
    priceAlerts = false;
    
    document.body.classList.remove('dark-mode');
    localStorage.removeItem('user_settings');
    
    addNotification({
      text: 'Settings reset to defaults',
      type: 'info',
      position: 'top-right',
      removeAfter: 3000
    });
  };
</script>

<div class="settings-container">
  <div class="settings-header">
    <h2>Application Settings</h2>
  </div>
  
  <div class="settings-grid">
    <div class="settings-card">
      <h3>General Settings</h3>
      
      <div class="settings-group">
        <div class="setting-item">
          <label for="dark-mode">Dark Mode</label>
          <div class="toggle-switch">
            <input type="checkbox" id="dark-mode" bind:checked={darkMode} />
            <span class="toggle-slider"></span>
          </div>
        </div>
        
        <div class="setting-item">
          <label for="refresh-interval">Data Refresh Interval (seconds)</label>
          <input 
            type="number"
            id="refresh-interval"
            bind:value={refreshInterval}
            min="5"
            max="300"
          />
        </div>
      </div>
      
      <button class="save-button" on:click={saveSettings} disabled={saving}>
        {#if saving}
          <div class="spinner"></div>
          <span>Saving...</span>
        {:else}
          <span>Save Settings</span>
        {/if}
      </button>
    </div>
    
    <div class="settings-card">
      <h3>Notification Settings</h3>
      
      <div class="settings-group">
        <div class="setting-item">
          <label for="email-notifications">Email Notifications</label>
          <div class="toggle-switch">
            <input type="checkbox" id="email-notifications" bind:checked={emailNotifications} />
            <span class="toggle-slider"></span>
          </div>
        </div>
        
        <div class="setting-item">
          <label for="trade-notifications">Trade Notifications</label>
          <div class="toggle-switch">
            <input type="checkbox" id="trade-notifications" bind:checked={tradeNotifications} />
            <span class="toggle-slider"></span>
          </div>
        </div>
        
        <div class="setting-item">
          <label for="price-alerts">Price Alerts</label>
          <div class="toggle-switch">
            <input type="checkbox" id="price-alerts" bind:checked={priceAlerts} />
            <span class="toggle-slider"></span>
          </div>
        </div>
      </div>
      
      <button class="save-button" on:click={saveSettings} disabled={saving}>
        {#if saving}
          <div class="spinner"></div>
          <span>Saving...</span>
        {:else}
          <span>Save Settings</span>
        {/if}
      </button>
    </div>
    
    <div class="settings-card">
      <h3>API Settings</h3>
      <p class="settings-description">
        Set your exchange API credentials. These are required for trading.
      </p>
      
      <div class="settings-group">
        <div class="setting-item vertical">
          <label for="api-key">API Key</label>
          <input 
            type="text"
            id="api-key"
            bind:value={apiKey}
            placeholder="Enter your API key"
          />
        </div>
        
        <div class="setting-item vertical">
          <label for="api-secret">API Secret</label>
          <input 
            type="password"
            id="api-secret"
            bind:value={apiSecret}
            placeholder="Enter your API secret"
          />
        </div>
        
        <div class="setting-item vertical">
          <label for="api-passphrase">API Passphrase</label>
          <input 
            type="password"
            id="api-passphrase"
            bind:value={apiPassphrase}
            placeholder="Enter your API passphrase"
          />
        </div>
      </div>
      
      <button class="save-button" on:click={saveApiSettings} disabled={saving}>
        {#if saving}
          <div class="spinner"></div>
          <span>Saving...</span>
        {:else}
          <span>Save API Settings</span>
        {/if}
      </button>
    </div>
    
    <div class="settings-card">
      <h3>Account Settings</h3>
      
      {#if user}
        <div class="account-info">
          <div class="info-item">
            <span class="info-label">Username:</span>
            <span class="info-value">{user.username}</span>
          </div>
          
          <div class="info-item">
            <span class="info-label">Role:</span>
            <span class="info-value">{user.role}</span>
          </div>
        </div>
      {/if}
      
      <div class="account-actions">
        <button class="reset-button" on:click={resetSettings}>
          Reset Settings
        </button>
        
        <button class="logout-button" on:click={() => authService.logout()}>
          Log Out
        </button>
      </div>
    </div>
  </div>
</div>

<style>
  .settings-container {
    width: 100%;
  }
  
  .settings-header {
    margin-bottom: 1.5rem;
  }
  
  .settings-header h2 {
    margin: 0;
    font-weight: 600;
    font-size: 1.5rem;
    color: #1a202c;
  }
  
  .settings-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }
  
  .settings-card {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    padding: 1.5rem;
  }
  
  .settings-card h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    font-size: 1.25rem;
    font-weight: 500;
    color: #2d3748;
    border-bottom: 1px solid #e2e8f0;
    padding-bottom: 0.5rem;
  }
  
  .settings-description {
    font-size: 0.875rem;
    color: #718096;
    margin-bottom: 1rem;
  }
  
  .settings-group {
    margin-bottom: 1.5rem;
  }
  
  .setting-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 1rem;
  }
  
  .setting-item.vertical {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .setting-item label {
    font-weight: 500;
    color: #4a5568;
  }
  
  .setting-item.vertical label {
    margin-bottom: 0.5rem;
  }
  
  .setting-item input[type="text"],
  .setting-item input[type="password"],
  .setting-item input[type="number"] {
    padding: 0.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 0.875rem;
  }
  
  .setting-item.vertical input {
    width: 100%;
  }
  
  .toggle-switch {
    position: relative;
    display: inline-block;
    width: 48px;
    height: 24px;
  }
  
  .toggle-switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }
  
  .toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #cbd5e0;
    transition: .4s;
    border-radius: 34px;
  }
  
  .toggle-slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: .4s;
    border-radius: 50%;
  }
  
  input:checked + .toggle-slider {
    background-color: #4299e1;
  }
  
  input:checked + .toggle-slider:before {
    transform: translateX(24px);
  }
  
  .save-button,
  .reset-button,
  .logout-button {
    padding: 0.75rem 1rem;
    border: none;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .save-button {
    background-color: #4299e1;
    color: white;
    width: 100%;
  }
  
  .save-button:hover {
    background-color: #3182ce;
  }
  
  .save-button:disabled {
    background-color: #a0aec0;
    cursor: not-allowed;
  }
  
  .account-info {
    margin-bottom: 1.5rem;
  }
  
  .info-item {
    margin-bottom: 0.5rem;
  }
  
  .info-label {
    font-weight: 500;
    color: #4a5568;
    margin-right: 0.5rem;
  }
  
  .info-value {
    color: #2d3748;
  }
  
  .account-actions {
    display: flex;
    gap: 1rem;
  }
  
  .reset-button {
    background-color: #f7fafc;
    color: #4a5568;
    border: 1px solid #e2e8f0;
    flex: 1;
  }
  
  .reset-button:hover {
    background-color: #edf2f7;
  }
  
  .logout-button {
    background-color: #fed7d7;
    color: #c53030;
    flex: 1;
  }
  
  .logout-button:hover {
    background-color: #feb2b2;
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
  
  @media (max-width: 768px) {
    .settings-grid {
      grid-template-columns: 1fr;
    }
  }
</style>
