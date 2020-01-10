defmodule RleParser do
  def parse(rle_string) do
    [_x, x, _y, y, _rule, rule | lines] =
      rle_string
      |> String.split([",", "=", "\n", "$", "!"], trim: true)

    result = %{
      x: x |> String.trim |> String.to_integer,
      y: y |> String.trim |> String.to_integer,
      rule: rule |> String.trim,
      lines: lines
    }

    cells = []
    row = result.x
    _col = result.y
    lines
    |> Enum.map_reduce(%{row: row, cells: cells}, fn line, acc ->
      cells = parse_line(line, acc.row, acc.cells)
      %{row: acc.row-1, cells: cells}
    end)
  end

  def parse_line(line, row, cells) do
    line_to_parts(line)
    |> add_cells(row, 1, cells)
  end

  def line_to_parts(line) do
    Regex.split(~r{(\d*[ob])}, line, trim: true, include_captures: true)
    |> Enum.map(fn
      "o" -> "1o"
      "b" -> "1b"
      other -> other
    end)
  end

  def add_cells([], _row, _col, cells) do
    cells
  end

  def add_cells([command|rest], row, col, cells) do
    case Integer.parse(command) do
      {count, "o"} ->
        case count do
          0 ->
            IO.puts "Down to 0, nothing more to add"
            cells
          _ ->
            cells = [%Cell{x: row, y: col} | cells]
            IO.puts "Added new cell, calling with #{count-1}"
            IO.inspect cells
            add_cells(["#{count-1}o"|rest], row, col+1, cells)
        end
      {count, "b"} ->
        IO.puts "I'm supposed to do #{command}...recursing..."
        add_cells([rest], row, col+count, cells)
    end
  end
end
