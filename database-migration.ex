defmodule CryptoBot.Repo.Migrations.CreatePositions do
  use Ecto.Migration

  def change do
    create table(:positions) do
      add :symbol, :string, null: false
      add :position_type, :string, null: false
      add :entry_price, :decimal, precision: 18, scale: 8, null: false
      add :exit_price, :decimal, precision: 18, scale: 8
      add :position_size, :decimal, precision: 18, scale: 8, null: false
      add :leverage, :integer, null: false
      add :status, :string, null: false, default: "open"
      add :profit_loss, :decimal, precision: 18, scale: 8
      add :profit_loss_percent, :decimal, precision: 10, scale: 2
      add :closed_at, :utc_datetime
      
      timestamps()
    end
    
    # Create indexes
    create index(:positions, [:symbol])
    create index(:positions, [:status])
    create index(:positions, [:inserted_at])
  end
end
