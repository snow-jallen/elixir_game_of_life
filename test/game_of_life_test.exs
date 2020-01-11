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

      %{x: 3, y: 3, rule: "B3/S23", lines: lines} = RleParser.parse(rle)
      inspect lines
    end

    test "parse line - single cell on" do
      actual = RleParser.parse_line("o", 3, 3, [])
      expected = [%Cell{x: 1, y: 3}]

      assert expected == actual
    end
  end

end

"""
x = 24, y = 35, rule = B3/S23
o$o$o$o$o$o10b7o$bo7b2o3b2ob2o$b2o5b2o2b5ob2o$2b2o3bo3b2o4bobo$3bob2o
3b2o6b2o$4b2o3bo5b5o$3b3o2b2o4b2o3bo$2b2o2b3o4bo5bo$bo5b2o4bo5bo$2o5b
3o2b2o4bo$o6bo2bobo4b2o$o6bo3b6o$o6bo4bo$o6bo3b2o$o6bo3bo$3o4bo3bo$2b
21o$8bo2bo11bo$8bo2bo11bo$9b3o11bo$10b2o10b2o$11b4o5b3o$12bo2b5o$12bo$
12bo$12bo$12bo$12bo$12bo$12bo!



"""
