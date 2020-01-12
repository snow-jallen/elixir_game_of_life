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
    row = result.y
    {_row, cells} = lines
      |> Enum.reduce({row, cells}, fn line, {row, cells} ->
        cells = parse_line(line, row, cells)
        {row - 1, cells}
      end)
    cells
  end

  def parse_line(line, row, cells) do
    {cells, _row, _col} = line_to_parts(line)
      |> Enum.reduce({cells, row, 1}, fn part, {cells, row, col} ->
        %{cells: cells, col: new_col} = add_cells(part, row, col, cells)
        {cells, row, new_col}
      end)
    cells
  end

  def line_to_parts(line) do
    Regex.split(~r{(\d*[ob])}, line, trim: true, include_captures: true)
    |> Enum.map(fn
      "o" -> "1o"
      "b" -> "1b"
      other -> other
    end)
  end

  def add_cells(command, row, col, cells) do
    case Integer.parse(command) do
      {count, "o"} ->
        case count do
          0 ->
            %{cells: cells, col: col}
          _ ->
            cells = [%Cell{x: col, y: row} | cells]
            add_cells("#{count-1}o", row, col+1, cells)
        end
      {count, "b"} ->
        %{cells: cells, col: col + count}
    end
  end
end
