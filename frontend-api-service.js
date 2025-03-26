// src/utils/api.js
import axios from 'axios';

// Create axios instance
const api = axios.create({
  baseURL: 'http://localhost:4000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Add request interceptor for auth tokens
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Add response interceptor for error handling
api.interceptors.response.use(
  response => {
    return response;
  },
  error => {
    if (error.response && error.response.status === 401) {
      // Logout user if token is expired or invalid
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth services
export const authService = {
  login: async (username, password) => {
    try {
      const response = await api.post('/auth/login', { username, password });
      if (response.data.success) {
        localStorage.setItem('auth_token', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
      }
      return response.data;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },
  
  logout: async () => {
    try {
      await api.post('/auth/logout');
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
    } catch (error) {
      console.error('Logout error:', error);
      // Still clear local storage even if API call fails
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
    }
  },
  
  isAuthenticated: () => {
    return !!localStorage.getItem('auth_token');
  },
  
  getUser: () => {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  }
};

// Trading services
export const tradingService = {
  startTrading: async (config) => {
    try {
      const response = await api.post('/trading/start', config);
      return response.data;
    } catch (error) {
      console.error('Start trading error:', error);
      throw error;
    }
  },
  
  stopTrading: async () => {
    try {
      const response = await api.post('/trading/stop');
      return response.data;
    } catch (error) {
      console.error('Stop trading error:', error);
      throw error;
    }
  },
  
  getStatus: async () => {
    try {
      const response = await api.get('/trading/status');
      return response.data;
    } catch (error) {
      console.error('Get status error:', error);
      throw error;
    }
  },
  
  getPositions: async (filters = {}) => {
    try {
      const response = await api.get('/positions', { params: filters });
      return response.data;
    } catch (error) {
      console.error('Get positions error:', error);
      throw error;
    }
  }
};

// Market data services
export const marketService = {
  getSymbols: async () => {
    try {
      const response = await api.get('/symbols');
      return response.data;
    } catch (error) {
      console.error('Get symbols error:', error);
      throw error;
    }
  },
  
  getMarketData: async (symbol, timeframe = '15m') => {
    try {
      const response = await api.get(`/market/${symbol}`, { params: { timeframe } });
      return response.data;
    } catch (error) {
      console.error('Get market data error:', error);
      throw error;
    }
  }
};

export default api;
