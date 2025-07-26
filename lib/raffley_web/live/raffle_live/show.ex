defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-show">
      <h1>Raffle Show</h1>
      <p>This is the show page for a raffle.</p>
    </div>
    """
  end
end
