defmodule LiveArt.Repo do
  use Ecto.Repo,
    otp_app: :live_art,
    adapter: Ecto.Adapters.SQLite3
end
