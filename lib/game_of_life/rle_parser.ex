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
        {cells, row} = parse_line(line, row, cells)
        {row - 1, cells}
      end)
    cells
  end

  def parse_line(line, row, cells) do
    {cells, row, _col} = line_to_parts(line)
      |> Enum.reduce({cells, row, 1}, fn part, {cells, row, col} ->
        case ends_in_o_or_b(part) do
          true ->
            %{cells: cells, col: new_col} = add_cells(part, row, col, cells)
            {cells, row, new_col}
          false ->
            # The row will naturally be decreased by 1 so we skip 1 less row
            rows_to_skip = String.to_integer(part) - 1
            {cells, row - rows_to_skip, col}
        end
      end)
    {cells, row}
  end

  def ends_in_o_or_b(part) do
    String.contains?(part, "o") || String.contains?(part, "b")
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

  def dump(cells) do
    cells
    |> Enum.sort(&(&1.y >= &2.y && &1.x <= &2.x))
    |> Enum.group_by(&(&1.y), &(&1.x))
    |> Enum.sort
    |> Enum.reverse
    |> IO.inspect(label: "sort, group_by, sort, reverse")
    |> Enum.reduce("x = ?, y = ?, rule = B3/S23\n", fn {row, cells}, rle ->
      IO.puts "row: #{row}, cells: #{inspect cells}"
      rle <> encode_row(cells)
    end)
    |> IO.inspect(label: "after reduce")

  end

  def encode_row(cells) do
    

  end
end
