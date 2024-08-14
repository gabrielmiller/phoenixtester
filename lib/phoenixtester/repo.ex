defmodule Phoenixtester.Repo do
  use Ecto.Repo,
    otp_app: :phoenixtester,
    adapter: Ecto.Adapters.Postgres
end
