# Create the Elixir Phoenix project
mix phx.new backend --no-html --no-assets --no-mailer --no-dashboard --no-gettext --no-live

# Change to the project directory
cd backend

# Add dependencies
mix deps.get

# Create database
mix ecto.create

# Generate structure
mkdir -p lib/crypto_bot/exchanges
mkdir -p lib/crypto_bot/strategies
mkdir -p lib/crypto_bot/indicators
mkdir -p lib/crypto_bot/traders
mkdir -p lib/crypto_bot/schemas
