defmodule Icyboard.Repo do
  use Ecto.Repo,
    otp_app: :icyboard,
    adapter: Ecto.Adapters.Postgres
end
