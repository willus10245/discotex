defmodule DiscotexBot.Application do
  @moduledoc false

  use Application

  alias DiscotexBot.DiscordClient

  def start(_type, _args) do
    Supervisor.start_link(children(), strategy: :one_for_one, name: DiscotexBot.Supervisor)
  end

  defp children do
    [
      configure(DiscordClient),
      {Registry, keys: :unique, name: Registry.ChannelContexts}
    ]
    |> List.flatten()
  end

  defp configure(process) do
    if should_start?(process) do
      process
    else
      []
    end
  end

  defp should_start?(process) do
    Application.get_env(:discotex_bot, process, [])[:enabled] == true
  end
end
