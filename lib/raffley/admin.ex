defmodule Raffley.Admin do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle
  alias Raffley.Raffles
  import Ecto.Query

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  def change_raffle(%Raffle{} = raffle, attr \\ %{}) do
    Raffle.changeset(raffle, attr)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def update_raffle(%Raffle{} = raffle, attr) do
    raffle
    |> Raffle.changeset(attr)
    |> Repo.update()
    |> case do
      {:ok, raffle} ->
        raffle = raffle |> Repo.preload([:charity, :winning_ticket])
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}

      {:error, _} = error ->
        error
    end
  end

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle = Repo.preload(raffle, :tickets)

    case raffle.tickets do
      [] ->
        {:error, "No tickets to draw!"}

      tickets ->
        winner = Enum.random(tickets)

        {:ok, _raffle} =
          update_raffle(raffle, %{
            winning_ticket_id: winner.id
          })
    end
  end

  def draw_winner(%Raffle{}) do
    {:error, "Raffle must be closed to draw a winner!"}
  end

  def delete_raffle(%Raffle{} = raffle) do
    Repo.delete(raffle)
  end
end
