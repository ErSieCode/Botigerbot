defmodule CryptoBotWeb.API.AuthController do
  @moduledoc """
  Controller for authentication API endpoints.
  """
  
  use CryptoBotWeb, :controller
  require Logger
  
  # For simplicity, using a static admin user.
  # In a real application, this would come from a database.
  @admin_user %{
    id: 1,
    username: "admin",
    password_hash: Bcrypt.hash_pwd_salt("admin123"),
    role: "admin"
  }
  
  @doc """
  Authenticate a user by username and password.
  """
  def login(conn, %{"username" => username, "password" => password}) do
    # In a real app, look up the user in the database
    if username == @admin_user.username && Bcrypt.verify_pass(password, @admin_user.password_hash) do
      # Generate JWT token
      {:ok, token, _claims} = 
        CryptoBotWeb.Guardian.encode_and_sign(
          @admin_user,
          %{role: @admin_user.role},
          ttl: {1, :day}
        )
      
      conn
      |> put_status(:ok)
      |> json(%{
        success: true,
        token: token,
        user: %{
          id: @admin_user.id,
          username: @admin_user.username,
          role: @admin_user.role
        }
      })
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{success: false, error: "Invalid username or password"})
    end
  end
  
  @doc """
  Log out a user by invalidating their token.
  """
  def logout(conn, _params) do
    token = get_auth_token(conn)
    
    if token do
      # Revoke the token
      CryptoBotWeb.Guardian.revoke(token)
    end
    
    conn
    |> put_status(:ok)
    |> json(%{success: true, message: "Logged out successfully"})
  end
  
  # Helper functions
  
  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end

defmodule CryptoBotWeb.Guardian do
  @moduledoc """
  Implementation module for Guardian JWT authentication.
  """
  
  use Guardian, otp_app: :crypto_bot
  
  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end
  
  def resource_from_claims(claims) do
    id = claims["sub"] |> String.to_integer()
    user = %{id: id} # In a real app, fetch the user from the database
    {:ok, user}
  end
end
