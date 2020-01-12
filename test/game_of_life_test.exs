defmodule GameOfLifeTest do
  use ExUnit.Case

  describe "advance/1" do

    test "Rule 1: any adjacent cell with fewer than two neighbors dies as if by underpopulation" do
      starting_board = [%Cell{x: 1, y: 1}]
      actual_board = Board.advance(starting_board)
      expected_board = []

      assert expected_board == actual_board, "All cells should die as if by underpopulation"
    end

    test "Rule 2: any live cell with two or three neighbors lives on to the next generation" do
      starting_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}]
      actual_board = Board.advance(starting_board)
      expected_board = [%Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}, %Cell{x: 1, y: 2}, %Cell{x: 2, y: 2}]

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end

    test "Rule 3: any live cell with more than three neighbors dies, as if by overpopulation" do
      starting_board = [
                          %Cell{x: 2, y: 4}, %Cell{x: 3, y: 4}, %Cell{x: 4, y: 4},
                          %Cell{x: 2, y: 3}, %Cell{x: 3, y: 3}, %Cell{x: 4, y: 3},
                          %Cell{x: 2, y: 2}, %Cell{x: 3, y: 2}, %Cell{x: 4, y: 2},
      ]

      expected_board = [
                                              %Cell{x: 3, y: 5},
                           %Cell{x: 2, y: 4},                    %Cell{x: 4, y: 4},
        %Cell{x: 1, y: 3},                                                          %Cell{x: 5, y: 3},
                           %Cell{x: 2, y: 2},                    %Cell{x: 4, y: 2},
                                              %Cell{x: 3, y: 1},
      ]
      actual_board = Board.advance(starting_board)

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end

    test "Rule 4: any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction" do
      starting_board = [%Cell{x: 1, y: 1}, %Cell{x: 3, y: 1}, %Cell{x: 1, y: 3}]
      expected_board = [%Cell{x: 2, y: 2}]

      actual_board = Board.advance(starting_board)

      assert Enum.sort(expected_board) == Enum.sort(actual_board)
    end
  end

  describe "neighbor_count/2" do
    test "0 neighbors" do
      cell = %Cell{x: 1, y: 1}
      board = [cell]

      assert Board.neighbor_count(cell, board) == 0, "No neighbors"

    end
  end

  describe "parse_rle/1" do
    test "basic pattern" do
      rle = """
      x = 3, y = 3, rule = B3/S23
      o$obo$2o!
      """

      actual = RleParser.parse(rle) |> Enum.sort
      expected = [
        %Cell{x: 1, y: 3},
        %Cell{x: 1, y: 2}, %Cell{x: 3, y: 2},
        %Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}
      ] |> Enum.sort
      assert expected == actual
    end

    test "multiple blanks" do
      rle = """
      x = 9, y = 1, rule = B3/S23
      o2bo4bo!
      """

      actual = RleParser.parse(rle) |> Enum.sort
      expected = [
        %Cell{x: 1, y: 1}, %Cell{x: 4, y: 1},%Cell{x: 9, y: 1}
        ] |> Enum.sort
      assert expected == actual
    end

    test "multiple blank rows" do
      rle = """
        x = 2, y = 20, rule = B3/S23
        o9$2o10$o!
        """

      actual = RleParser.parse(rle) |> Enum.sort
      expected = [
        %Cell{y: 1, x: 1}, %Cell{y: 11, x: 1}, %Cell{y: 11, x: 2}, %Cell{y: 20, x: 1}
      ] |> Enum.sort
      assert expected == actual
    end
  end

  describe "dump_rle/1" do
    test "basic pattern" do
      starting = [
        %Cell{x: 1, y: 3},
        %Cell{x: 1, y: 2}, %Cell{x: 3, y: 2},
        %Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}
      ]

      expected_rle = """
      x = 3, y = 3, rule = B3/S23
      o$obo$2o!
      """
      actual_rle = RleParser.dump(starting)

      assert expected_rle == actual_rle
    end

    test "encode_row - single cell" do
      actual = RleParser.encode_row("[1]")
      expected = "o"
      assert expected == actual
    end

    test "encode_row continuous cells" do
      actual = RleParser.encode_row([1,2,3])
      expected = "3o"
      assert expected == actual
    end

    test "encode_row runs and skips" do
      actual = RleParser.encode_row([1,2,6,7,8,22,50])
      expected = "2o3b3o13bo27bo$"
      assert expected == actual
    end
  end

end

_sample = """
x = 24, y = 35, rule = B3/S23
o$o$o$o$o$o10b7o$bo7b2o3b2ob2o$b2o5b2o2b5ob2o$2b2o3bo3b2o4bobo$3bob2o
3b2o6b2o$4b2o3bo5b5o$3b3o2b2o4b2o3bo$2b2o2b3o4bo5bo$bo5b2o4bo5bo$2o5b
3o2b2o4bo$o6bo2bobo4b2o$o6bo3b6o$o6bo4bo$o6bo3b2o$o6bo3bo$3o4bo3bo$2b
21o$8bo2bo11bo$8bo2bo11bo$9b3o11bo$10b2o10b2o$11b4o5b3o$12bo2b5o$12bo$
12bo$12bo$12bo$12bo$12bo$12bo!
"""
_sample2 = """
x = 24, y = 19, rule = B3/S23
$4bo9b2o$4b3o8b2o$6b2o8b2o$7bo9bo$7b2o8b2o4bo$8bo14bo$23bo$o22bo$o22bo
$o21b2o$o21bo$o20b2o$2o18b2o$b2o16b2o$2b2o13b3o$3b2o10b3o$4b2o4b5o$5b
6o!
"""


_sample3 = """
x = 2, y = 20, rule = B3/S23
o9$2o10$o!
"""
