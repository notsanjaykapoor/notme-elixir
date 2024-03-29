defmodule NotmeWeb.Router do
  use NotmeWeb, :router

  alias NotmeWeb.{PlugAuthInit, PlugUserAuthenticated, PlugUserGuest, PlugUserTrack}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NotmeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PlugAuthInit
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # routes that require authenticated user
  scope "/", NotmeWeb do
    pipe_through [:browser, PlugUserAuthenticated, PlugUserTrack]

    live "/merchants/:merchant_id/live", MerchantLive
    live "/user/live", UserLive
  end

  # routes that require guest user
  scope "/", NotmeWeb do
    pipe_through [:browser, PlugUserGuest]

    get "/login", LoginController, :new
    post "/session", LoginController, :create
  end

  # routes that are open to any user
  scope "/", NotmeWeb do
    pipe_through [:browser, PlugUserTrack]

    get "/notme/:messenger", NotmeController, :show
    get "/notme", NotmeController, :index

    get "/logout", LogoutController, :index

    resources "/items", ItemController, only: [:index]
    resources "/me", MeController, only: [:index]
    resources "/merchants", MerchantController, only: [:index]
    live "/nodes/live", NodeLive
    resources "/options", OptionController, only: [:index]
    resources "/products", ProductController
    resources "/users", UserController, only: [:index]
    resources "/weather", WeatherController, only: [:index]

    get "/", PageController, :home
  end

  scope "/api", NotmeWeb do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:notme, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NotmeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
