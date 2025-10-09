defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view
  alias Raffley.Admin
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.header>
        {@page_title}
        <:actions>
          <.link class="button" navigate={~p"/admin/raffles/new"}>
            New Raffle
          </.link>
        </:actions>
      </.header>
      <.table
        id="raffles"
        rows={@streams.raffles}
        row_click={fn {_id, raffle} -> JS.navigate(~p"/raffles/#{raffle}") end}
      >
        <:col :let={{_dom_id, raffle}} label="Prize">
          <.link navigate={~p"/raffles/#{raffle}"}>
            {raffle.prize}
          </.link>
        </:col>
        <:col :let={{_dom_id, raffle}} label="Status">
          <.badge status={raffle.status} />
        </:col>
        <:col :let={{_dom_id, raffle}} label="Ticket Price">
          {raffle.ticket_price}
        </:col>
        <:col :let={{_dom_id, raffle}} label="Winning Ticket #">
          {raffle.winning_ticket_id}
        </:col>
        <:action :let={{_dom_id, raffle}}>
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{dom_id, raffle}}>
          <.link
            phx-click={delete_and_hide(dom_id, raffle)}
            phx-disable-with="Deleting..."
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
        <:action :let={{_dom_id, raffle}}>
          <.link phx-click="draw-winner" phx-value-id={raffle.id}>
            Draw Winner
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    raffle = Admin.get_raffle!(id)
    {:ok, _} = Admin.delete_raffle(raffle)
    {:noreply, stream_delete(socket, :raffles, raffle)}
  end

  def handle_event("draw-winner", %{"id" => id}, socket) do
    raffle = Admin.get_raffle!(id)

    case Admin.draw_winner(raffle) do
      {:ok, raffle} ->
        socket =
          socket
          |> put_flash(:info, "Winning ticket drawn!")
          |> stream_insert(:raffles, raffle)

        {:noreply, socket}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def delete_and_hide(dom_id, raffle) do
    JS.push("delete", value: %{id: raffle.id})
    |> JS.add_class("opacity-50", to: "##{dom_id}")
  end
end
