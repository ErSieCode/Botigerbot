defmodule CryptoBot.Schemas.Position do
  @moduledoc """
  Schema for tracking trading positions.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias CryptoBot.Schemas.Position
  
  schema "positions" do
    field :symbol, :string
    field :position_type, Ecto.Enum, values: [:long, :short]
    field :entry_price, :decimal
    field :exit_price, :decimal
    field :position_size, :decimal
    field :leverage, :integer
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :profit_loss, :decimal
    field :profit_loss_percent, :decimal
    field :closed_at, :utc_datetime
    
    timestamps()
  end
  
  @doc """
  Changeset function for a position.
  """
  def changeset(%Position{} = position, attrs) do
    position
    |> cast(attrs, [
      :symbol, 
      :position_type, 
      :entry_price, 
      :exit_price, 
      :position_size, 
      :leverage, 
      :status, 
      :profit_loss, 
      :profit_loss_percent, 
      :closed_at
    ])
    |> validate_required([
      :symbol, 
      :position_type, 
      :entry_price, 
      :position_size, 
      :leverage
    ])
  end
  
  @doc """
  Changeset to open a new position.
  """
  def open_position_changeset(attrs) do
    %Position{}
    |> cast(attrs, [
      :symbol, 
      :position_type, 
      :entry_price, 
      :position_size, 
      :leverage
    ])
    |> validate_required([
      :symbol, 
      :position_type, 
      :entry_price, 
      :position_size, 
      :leverage
    ])
    |> put_change(:status, :open)
  end
  
  @doc """
  Changeset to close an existing position.
  """
  def close_position_changeset(%Position{} = position, attrs) do
    position
    |> cast(attrs, [
      :exit_price, 
      :profit_loss, 
      :profit_loss_percent
    ])
    |> validate_required([
      :exit_price, 
      :profit_loss, 
      :profit_loss_percent
    ])
    |> put_change(:status, :closed)
    |> put_change(:closed_at, DateTime.utc_now())
  end
end
