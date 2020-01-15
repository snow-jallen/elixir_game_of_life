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
    boards = initialize_boards_with_x_coords(board, side_length)
    # boards is list
    boards = calculate_boards_y_coords(boards, side_length)
  end

  def initialize_boards_with_x_coords(board, step_size) do
    do_initialize_boards_with_x_coords(board.min_x, board.max_x, step_size, [])
  end

  def do_initialize_boards_with_x_coords(current_x, max_x, step_size, acc) do
    local_max = find_local_max(current_x, step_size)
    case local_max < max_x do
      true -> acc = [
                %Board{
                  min_x: current_x,
                  max_x: local_max
                } | acc]
              do_initialize_boards_with_x_coords(local_max+1, max_x, step_size, acc)
      false -> [
                %Board{
                  min_x: current_x,
                  max_x: local_max
                } | acc]
    end
  end

  def calculate_boards_y_coords([current_board | other_boards], side_length) do

  end

  def do_initialize_boards_with_y_coords(current_y, max_y, min_x, max_x, step_size, acc) do
    local_max = find_local_max(current_y, step_size)
    case local_max < max_y do
      true -> acc = [
                %Board{
                  min_y: current_y,
                  max_y: local_max
                } | acc]
              do_initialize_boards_with_x_coords(local_max+1, max_x, step_size, acc)
      false -> [
                %Board{
                  min_x: current_x,
                  max_x: local_max
                } | acc]
    end
  end

  def find_local_max(current, step_size) do
    local_max = current + step_size
    case local_max == 0 do
      true -> local_max + 1
      false -> local_max
    end
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
