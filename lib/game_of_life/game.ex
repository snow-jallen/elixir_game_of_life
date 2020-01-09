defmodule Game do
  def run(starting_board, 0) do
    starting_board
  end

  def run(starting_board, num_generations) do
    starting_board
    |> Board.advance()
    |> run(num_generations - 1)
  end
end
