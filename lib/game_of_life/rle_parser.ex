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
      #"#{rle} #{encode_row(cells)}"
      rle <> encode_row(cells)
    end)
    |> IO.inspect(label: "after reduce")

  end

  def encode_row(row) do
    case continuous(row, 0) do
      %{count: 1, remaining: []} -> "o$"
      %{count: prefix, remaining: []} -> "#{prefix}o$"
      %{count: prefix, remaining: remaining} -> "#{prefix}o"<>encode_row(remaining)
    end
  end

  def continuous([], num_in_a_row), do: %{count: num_in_a_row, remaining: []}

  def continuous([_x], num_in_a_row), do: %{count: num_in_a_row+1, remaining: []}

  def continuous([x, x1 | rest], num_in_a_row) do
    case (x + 1 == x1) do
      true -> continuous([x1 | rest], num_in_a_row + 1)
      false -> %{count: num_in_a_row + 1, remaining: [x1 | rest]}
    end
  end

  def encode(row) do
    do_encode(1, row, "b", "")
  end

  defp do_encode(start, [single], command, acc) do
    case single - start do
      0 -> acc<>next_command(command)<>"$"
      diff -> acc<>"#{diff}"<>command<>next_command(command)<>"$"
    end
  end

  defp do_encode(_start, _row = [1, 2], _command, acc) do
    acc <> "2o$"
  end

  defp do_encode(_start, _row = [1, other], _command, acc) do
    acc <> "o" <>
      case other - 2 do
        1 -> "bo$"
        diff -> "#{diff}bo$"
      end
  end

  defp do_encode(_start, _row = [next, other], _command, acc) when other == next + 1 do
    acc <>
      case next - 1 do
        1 -> "b"
        diff -> "#{diff}b"
      end
      <> "2o$"
  end

  defp do_encode(_start, _row = [next, other], _command, acc) do
    acc <>
      case next - 1 do
        1 -> "bo"
        diff -> "#{diff}bo"
      end
      <>
      case other - next - 1 do
        1 -> "bo$"
        diff -> "#{diff}bo$"
      end
  end

  defp do_encode(start, row = [next,second|rest], command, acc) do
    case next - start do
      0 -> do_encode(start, row, next_command(command), acc)
      1 -> do_encode(next, rest, next_command(command), acc<>"o")
      diff -> do_encode(next, rest, next_command(command), acc<>"#{diff}#{command}")
    end
  end

  defp next_command("o"), do: "b"
  defp next_command("b"), do: "o"
end
