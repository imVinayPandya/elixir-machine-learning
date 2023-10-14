defmodule News.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NewsWeb.Telemetry,
      News.Repo,
      {DNSCluster, query: Application.get_env(:news, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: News.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: News.Finch},
      # Start a worker by calling: News.Worker.start_link(arg)
      # {News.Worker, arg},
      # Start to serve requests, typically the last entry
      NewsWeb.Endpoint,
      News.Stream,
      {
        Nx.Serving,
        serving: News.Enrichments.NER.serving(), name: News.Enrichments.NER, batch_size: 8
        #  sequence_length: 128
      },
      {Nx.Serving,
       serving: News.Enrichments.Sentiment.serving(),
       name: News.Enrichments.Sentiment,
       batch_size: 8}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: News.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NewsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
