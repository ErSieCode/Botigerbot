<!-- src/routes/Login.svelte -->
<script>
  import { navigate } from 'svelte-navigator';
  import { authService } from '../utils/api';
  import { getNotificationsContext } from 'svelte-notifications';
  
  const { addNotification } = getNotificationsContext();
  
  let username = '';
  let password = '';
  let loading = false;
  let error = null;
  
  const handleSubmit = async () => {
    loading = true;
    error = null;
    
    try {
      const response = await authService.login(username, password);
      
      if (response.success) {
        addNotification({
          text: 'Login successful!',
          type: 'success',
          position: 'top-right',
          removeAfter: 3000
        });
        navigate('/');
      } else {
        error = response.error || 'Login failed';
      }
    } catch (err) {
      error = err.response?.data?.error || 'Login failed';
    } finally {
      loading = false;
    }
  };
</script>

<div class="login-container">
  <div class="login-card">
    <div class="login-header">
      <div class="logo">
        <span class="logo-icon">📈</span>
        <span class="logo-text">CryptoBot</span>
      </div>
      <h1>Login</h1>
      <p>Sign in to access your trading dashboard</p>
    </div>
    
    <form on:submit|preventDefault={handleSubmit} class="login-form">
      {#if error}
        <div class="error-alert">
          <svg viewBox="0 0 24 24" width="18" height="18">
            <path fill="currentColor" d="M13,13H11V7H13M13,17H11V15H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z" />
          </svg>
          <span>{error}</span>
        </div>
      {/if}
      
      <div class="form-group">
        <label for="username">Username</label>
        <input 
          type="text" 
          id="username" 
          bind:value={username} 
          required 
          disabled={loading} 
          placeholder="Enter your username"
        />
      </div>
      
      <div class="form-group">
        <label for="password">Password</label>
        <input 
          type="password" 
          id="password" 
          bind:value={password} 
          required 
          disabled={loading} 
          placeholder="Enter your password"
        />
      </div>
      
      <button type="submit" class="login-button" disabled={loading}>
        {#if loading}
          <div class="spinner"></div>
          <span>Signing in...</span>
        {:else}
          <span>Sign In</span>
        {/if}
      </button>
    </form>
    
    <div class="demo-info">
      <p>For demo purposes, use the following credentials:</p>
      <code>Username: admin</code>
      <code>Password: admin123</code>
    </div>
  </div>
</div>

<style>
  .login-container {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    background-color: #f5f7fa;
  }
  
  .login-card {
    width: 100%;
    max-width: 400px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    overflow: hidden;
  }
  
  .login-header {
    padding: 2rem;
    background-color: #1a202c;
    color: white;
    text-align: center;
  }
  
  .logo {
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }
  
  .logo-icon {
    margin-right: 0.5rem;
    font-size: 1.75rem;
  }
  
  .login-header h1 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 500;
  }
  
  .login-header p {
    margin: 0.5rem 0 0;
    opacity: 0.8;
  }
  
  .login-form {
    padding: 2rem;
  }
  
  .form-group {
    margin-bottom: 1.5rem;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: #4a5568;
  }
  
  .form-group input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 1rem;
    transition: all 0.2s ease;
  }
  
  .form-group input:focus {
    outline: none;
    border-color: #4299e1;
    box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.2);
  }
  
  .login-button {
    width: 100%;
    padding: 0.75rem;
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
    justify-content: center;
  }
  
  .login-button:hover {
    background-color: #3182ce;
  }
  
  .login-button:disabled {
    background-color: #a0aec0;
    cursor: not-allowed;
  }
  
  .error-alert {
    background-color: #fed7d7;
    color: #c53030;
    padding: 0.75rem;
    border-radius: 4px;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
  }
  
  .error-alert svg {
    margin-right: 0.5rem;
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
  
  .demo-info {
    padding: 1rem 2rem 2rem;
    background-color: #f7fafc;
    border-top: 1px solid #e2e8f0;
    font-size: 0.875rem;
    color: #4a5568;
  }
  
  .demo-info p {
    margin: 0 0 0.5rem;
  }
  
  .demo-info code {
    display: block;
    margin-top: 0.25rem;
    padding: 0.25rem 0.5rem;
    background-color: #edf2f7;
    border-radius: 4px;
    font-family: monospace;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
