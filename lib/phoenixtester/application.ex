defmodule Phoenixtester.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixtesterWeb.Telemetry,
      Phoenixtester.Repo,
      {DNSCluster, query: Application.get_env(:phoenixtester, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Phoenixtester.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Phoenixtester.Finch},
      # Start a worker by calling: Phoenixtester.Worker.start_link(arg)
      # {Phoenixtester.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixtesterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phoenixtester.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixtesterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
