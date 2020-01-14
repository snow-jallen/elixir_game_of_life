defmodule Board do
  defstruct livecells: [],
            min_x: :negative_infinity,
            max_x: :positive_infinity,
            min_y: :negative_infinity,
            max_y: :positive_infinity

  def split(board, num_partitions) do
    # return list of boards with an extra cell on each side
  end

  def combine(boards) when is_list(boards) do
    # put the partial boards together, ignoring the outermost layer
  end


  def advance(current_board) do
    relevent_cells = Enum.reduce(current_board, [], fn cell, acc ->
      [cell | neighbors(cell)] ++ acc
    end)
    |> Enum.uniq

    Enum.reduce(relevent_cells, [], fn cell, acc ->
      case cell_should_live?(cell, current_board) do
        true -> [ cell | acc ]
        _ -> acc
      end
    end)
  end

  def cell_should_live?(cell, board) do
    case neighbor_count(cell, board) do
      n when n < 2 -> false
      n when n == 2 -> Enum.member?(board, cell)
      n when n == 3 -> true
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
      %Cell{x: translate(cell.x, -1), y: translate(cell.y, 0)},
      %Cell{x: translate(cell.x, -1), y: translate(cell.y,-1)},
      %Cell{x: translate(cell.x,  0), y: translate(cell.y,+1)},
      %Cell{x: translate(cell.x,  0), y: translate(cell.y,-1)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y,+1)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y, 0)},
      %Cell{x: translate(cell.x, +1), y: translate(cell.y,-1)}
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
