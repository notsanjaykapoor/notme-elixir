defmodule NotmeWebApp.Presence do
  use Phoenix.Presence,
    otp_app: :notme,
    pubsub_server: Notme.PubSub
end
