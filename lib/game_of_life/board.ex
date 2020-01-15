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

  def split(master_board, side_length) do
    boards_with_dimensions = initialize_list_of_boards(master_board, side_length)
    Enum.map(boards_with_dimensions, fn board ->
      %{ board | livecells: get_live_cells_in_board(board, master_board) }
    end)
  end

  def initialize_list_of_boards(%Board{} = board, side_length) do
    num_x_divisions = div(board.max_x - board.min_x, side_length) + 1
    num_y_divisions = div(board.max_y - board.min_y, side_length) + 1

    for i <- 1..num_x_divisions, j <- 1..num_y_divisions do
        %Board{
          min_x: safe_min(board.min_x + (i-1)*side_length),
          max_x: safe_max(board.min_x + (i)*side_length),
          min_y: safe_min(board.min_y + (j-1)*side_length),
          max_y: safe_max(board.min_y + (j)*side_length)
        }
    end
  end

  def safe_min(number) do
    case number do
      0 -> 1
      _ -> number
    end
  end

  def safe_max(number) do
    case number do
      0 -> -1
      _ -> number
    end
  end

  def get_live_cells_in_board(board, master_board) do
    Enum.reduce(master_board.livecells, [], fn cell, acc ->
      case cell.x < board.max_x
       and cell.x > board.min_x
       and cell.y < board.max_y
       and cell.y > board.min_y do
        true -> [cell | acc]
        false -> acc
      end
    end)
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
