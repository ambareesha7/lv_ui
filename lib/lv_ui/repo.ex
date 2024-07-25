defmodule LvUi.Repo do
  use Ecto.Repo,
    otp_app: :lv_ui,
    adapter: Ecto.Adapters.SQLite3
end
