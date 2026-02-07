defmodule CreatorPulse.Repo do
  use Ecto.Repo,
    otp_app: :creator_pulse,
    adapter: Ecto.Adapters.Postgres
end
