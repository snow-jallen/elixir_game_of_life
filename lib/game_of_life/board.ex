defmodule Board do
  defstruct livecells: []

  def advance(current_board) do
    cells_remain_alive =
      current_board
      |> Enum.filter(fn c -> cell_should_live?(c, current_board) end)

    cells_become_alive = []

    for cell <- current_board, neighbor <- neighbors(cell) do
      case cell_should_live?(neighbor, current_board) do
        true -> [neighbor | cells_become_alive]
        _ -> cells_become_alive
      end
    end

    cells_remain_alive ++ cells_become_alive
    |> Enum.uniq
  end

  def cell_should_live?(cell, board) do
    case neighbor_count(cell, board) do
      n when n < 2 -> false
      n when n <= 3 -> true
      n when n > 3 -> false
    end
  end

  def neighbor_count(cell, board) do
    neighbors(cell)
    |> Enum.filter(fn neighbor -> Enum.member?(board, neighbor) end)
    |> Enum.count
  end

  def neighbors(%Cell{} = cell) do
    [
      %Cell{x: translate(cell.x, -1), y: translate(cell.y,+1)},
      %Cell{x: translate(cell.x,  0), y: translate(cell.y,+1)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y,+1)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y,0)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y,-1)},
      %Cell{x: translate(cell.x, 0), y: translate(cell.y,-1)},
      %Cell{x: translate(cell.x, -1), y: translate(cell.y,-1)},
      %Cell{x: translate(cell.x, -1), y: translate(cell.y,0)}
    ]
  end

  def translate(orig, change) do
    newVal = orig + change
    case newVal do
      0 -> newVal + change
      _ -> newVal
    end
  end
end
