defmodule TrainsWeb.PageLive do
  use Phoenix.LiveView
  alias Phoenix.Socket.Broadcast
  alias Trains.Change
  alias TrainsWeb.Endpoint

  def render(assigns) do
    ~L"""
    <p>Movement Speed Change: <%= @change %></p>
    <button phx-click="decrement" phx-throttle="500">-</button>
    <button phx-click="increment" phx-throttle="500">+</button>
    """
  end

  def mount(_, socket) do
    if connected?(socket) do
      Endpoint.subscribe("change")
    end

    change = Change.state()

    {:ok, assign(socket, change: change)}
  end

  def handle_event("decrement", _event, socket) do
    change = Change.decrement()
    Endpoint.broadcast_from!(self(), "change", "update", %{change: change})
    {:noreply, assign(socket, change: change)}
  end

  def handle_event("increment", _event, socket) do
    change = Change.increment()
    Endpoint.broadcast_from!(self(), "change", "update", %{change: change})
    {:noreply, assign(socket, change: change)}
  end

  def handle_info(
        %Broadcast{topic: "change", event: "update", payload: %{change: change}},
        socket
      ) do
    {:noreply, assign(socket, change: change)}
  end
end
