defmodule Board do
  defstruct livecells: [],
            min_x: 0,
            max_x: 0,
            min_y: 0,
            max_y: 0

  def create([first_cell | other_cells]) do
    %Board{
      livecells: [first_cell],
      min_x: first_cell.x,
      max_x: first_cell.x,
      min_y: first_cell.y,
      max_y: first_cell.y
    }
    |> do_create(other_cells)
  end

  def create([]) do
    %Board{}
  end

  def do_create(board, []) do
    board
  end

  def do_create(%Board{} = board, [next_cell | other_cells]) do
    %Board{
      livecells: [next_cell | board.livecells],
      min_x: smaller_number(board.min_x, next_cell.x),
      max_x: larger_number(board.max_x, next_cell.x),
      min_y: smaller_number(board.min_y, next_cell.y),
      max_y: larger_number(board.max_y, next_cell.y)
    }
    |> do_create(other_cells)
  end

  def smaller_number(num1, num2) do
    case num1 < num2 do
      true -> num1
      false -> num2
    end
  end

  def larger_number(num1, num2) do
    case num1 < num2 do
      true -> num2
      false -> num1
    end
  end

  def split(board, side_length) do
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
