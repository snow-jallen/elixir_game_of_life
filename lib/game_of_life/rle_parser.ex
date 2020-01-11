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

    IO.inspect result

    # cells = []
    # row = result.x
    # _col = result.y
    # lines
    # |> Enum.map_reduce(%{row: row, cells: cells}, fn line, acc ->
    #   cells = parse_line(line, acc.row, acc.cells)
    #   %{row: acc.row-1, cells: cells}
    # end)
  end

  def parse_line(line, row, cells) do
    line_to_parts(line)
    |> IO.inspect
    |> Enum.flat_map_reduce(%{cells: cells, row: row}, fn part, acc ->
      cells = add_cells(part, acc.row, 1, acc.cells)
      IO.puts "Finished add_cells(#{inspect part}, #{row}, 1, #{inspect acc})"
      acc = %{acc | row: acc.row-1, cells: cells}
      acc
      |> IO.inspect
    end)
  end

  def line_to_parts(line) do
    Regex.split(~r{(\d*[ob])}, line, trim: true, include_captures: true)
    |> Enum.map(fn
      "o" -> "1o"
      "b" -> "1b"
      other -> other
    end)
  end

  def add_cells([], _row, col, cells) do
    IO.puts "reached add_cells base case. col=#{col}, cells=#{inspect cells}"
    %{cells: cells, col: col}
  end

  def add_cells(command, row, col, cells) do
    IO.puts "starting add_cells with #{inspect command}, #{row}, #{col}, #{inspect cells}"
    case Integer.parse(command) do
      {count, "o"} ->
        case count do
          0 ->
            IO.puts "Down to 0, nothing more to add"
            cells
          _ ->
            cells = [%Cell{x: col, y: row} | cells]
            IO.puts "Added new cell, calling with #{count-1}"
            IO.inspect cells
            add_cells("#{count-1}o", row, col+1, cells)
        end
      {count, "b"} ->
        IO.puts "I'm supposed to do #{count} blanks"
        IO.puts "calling add_cells with [], #{row}, #{col+count}, #{inspect cells}"
        add_cells([], row, col+count, cells)
    end
  end
end
