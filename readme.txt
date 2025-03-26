# CryptoBot Trading Platform

A complete cryptocurrency trading bot with an Elixir backend and Svelte frontend. This platform allows for automated trading of multiple cryptocurrencies using technical indicators and adaptive strategies.

## Features

- **Multi-Cryptocurrency Support**: Trade BTC, ETH, SOL, XRP and more
- **Technical Indicators**: RSI, SMA, Bollinger Bands, and Momentum
- **Risk Management**: Configurable stop-loss and take-profit levels
- **Interactive Dashboard**: Real-time monitoring of positions and performance
- **Market Data Visualization**: Candlestick charts and volume analysis
- **Position Tracking**: Monitor open and closed positions
- **User Authentication**: Secure login and settings management
- **Dark Mode Support**: Customizable user interface theme

## Technology Stack

- **Backend**: Elixir + Phoenix Framework
- **Frontend**: Svelte
- **Database**: PostgreSQL
- **API Integration**: Bitget Exchange API
- **Containerization**: Docker + Docker Compose

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- API credentials from a supported cryptocurrency exchange (Bitget)

## Project Structure

```
crypto_trading_bot/
├── backend/                # Elixir backend application
│   ├── lib/
│   │   ├── crypto_bot/     # Core trading logic
│   │   └── crypto_bot_web/ # Web API
│   ├── Dockerfile
│   └── ...
├── frontend/               # Svelte frontend application
│   ├── src/
│   │   ├── components/     # UI components
│   │   ├── routes/         # Application pages
│   │   ├── stores/         # State management
│   │   └── ...
│   ├── Dockerfile
│   └── ...
├── docker-compose.yml
└── README.md
```

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/crypto_trading_bot.git
   cd crypto_trading_bot
   ```

2. Set up environment variables (create a `.env` file in the project root):
   ```
   BITGET_API_KEY=your_api_key
   BITGET_API_SECRET=your_api_secret
   BITGET_API_PASSPHRASE=your_api_passphrase
   ```

3. Start the application:
   ```bash
   docker-compose up -d
   ```

4. Access the application:
   - Frontend: [http://localhost:3000](http://localhost:3000)
   - Backend API: [http://localhost:4000/api](http://localhost:4000/api)

5. Login with default credentials:
   - Username: `admin`
   - Password: `admin123`

## Development Setup

### Backend (Elixir)

1. Install Elixir and Phoenix dependencies:
   ```bash
   cd backend
   mix deps.get
   mix ecto.setup
   ```

2. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

### Frontend (Svelte)

1. Install Node.js dependencies:
   ```bash
   cd frontend
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

## Trading Strategy

The trading strategy utilized in this bot combines multiple technical indicators:

- **RSI (Relative Strength Index)**: Identifies overbought and oversold conditions
- **SMA (Simple Moving Average)**: Detects trend direction and strength
- **Bollinger Bands**: Measures volatility and potential reversal points
- **Momentum**: Confirms the strength of price movements

Entry and exit signals are generated based on combinations of these indicators, with configurable parameters for customization.

## Risk Management

The bot includes several risk management features:

- **Position Sizing**: Risk a configurable percentage of account balance per trade
- **Stop-Loss**: Automatically exit positions at predefined loss thresholds
- **Take-Profit**: Secure profits at predefined price targets
- **Leverage Control**: Set appropriate leverage levels for different market conditions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This trading bot is provided for educational and research purposes only. Cryptocurrency trading involves significant risk of loss and is not suitable for all investors. The developers are not responsible for any financial losses incurred from using this software.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
