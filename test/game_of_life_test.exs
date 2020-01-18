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

  describe "dump/1" do
    test "basic pattern" do
      starting = [
                                              %Cell{x: 3, y: 3},
        %Cell{x: 1, y: 2},                    %Cell{x: 3, y: 2},
        %Cell{x: 1, y: 1}, %Cell{x: 2, y: 1}
      ]

      expected = """
      x = 3, y = 3, rule = B3/S23
      2bo$obo$2o!
      """ |> String.trim
      actual = RleParser.dump(starting)
      assert expected == actual
    end

    test "handle negative cells" do
      starting = [
                                                %Cell{x: -3, y: -3},
        %Cell{x: -5, y: -4},                    %Cell{x: -3, y: -4},
        %Cell{x: -5, y: -5}, %Cell{x: -4, y: -5}
      ]

      expected = """
      x = 3, y = 3, rule = B3/S23
      2bo$obo$2o!
      """ |> String.trim
      actual = RleParser.dump(starting)
      assert expected == actual
    end

    test "encode - single cell" do
      actual = RleParser.encode([1])
      expected = "o$"
      assert expected == actual
    end

    test "encode continuous cells" do
      actual = RleParser.encode([1,2,3])
      expected = "3o$"
      assert expected == actual
    end

    test "encode runs and skips" do
      actual = RleParser.encode([1,2,6,7,8,22,50])
      expected = "2o3b3o13bo27bo$"
      assert expected == actual
    end

    test "encode [3]" do
      actual = RleParser.encode([3])
      expected = "2bo$"
      assert expected == actual
    end

    test "encode [1,2]" do
      actual = RleParser.encode([1,2])
      expected="2o$"
      assert expected==actual
    end

    test "encode [1,3]" do
      actual=RleParser.encode([1,3])
      expected="obo$"
      assert expected == actual
    end

    test "encode [1,4]" do
      actual=RleParser.encode([1,4])
      expected="o2bo$"
      assert expected == actual
    end

    test "encode [1,14]" do
      actual=RleParser.encode([1,14])
      expected="o12bo$"
      assert expected == actual
    end

    test "encode [2,3]" do
      actual=RleParser.encode([2,3])
      expected="b2o$"
      assert expected == actual
    end

    test "encode [10,11]" do
      actual=RleParser.encode([10,11])
      expected="9b2o$"
      assert expected == actual
    end

    test "encode [2,4]" do
      actual=RleParser.encode([2,4])
      expected="bobo$"
      assert expected == actual
    end

    test "encode [4,8]" do
      actual=RleParser.encode([4,8])
      expected="3bo3bo$"
      assert expected == actual
    end

    test "encode [1,2,3]" do
      actual=RleParser.encode([1,2,3])
      expected="3o$"
      assert expected == actual
    end
  end

  describe "count_sequence/1" do
    test "empty list" do
      actual = RleParser.count_sequence([])
      expected = 0
      assert expected == actual
    end

    test "[1]" do
      actual = RleParser.count_sequence([1])
      expected = 1
      assert expected == actual
    end

    test "[1,2]" do
      actual = RleParser.count_sequence([1,2])
      expected = 2
      assert expected == actual
    end

    test "[1,3]" do
      actual = RleParser.count_sequence([1,3])
      expected = 1
      assert expected == actual
    end

    test "[1,2,3]" do
      actual = RleParser.count_sequence([1,2,3])
      expected = 3
      assert expected == actual
    end

    test "[1,2,4]" do
      actual = RleParser.count_sequence([1,2,4])
      expected = 2
      assert expected == actual
    end

    test "[1,2,3,4,5,6]" do
      actual = RleParser.count_sequence([1,2,3,4,5,6])
      expected = 6
      assert expected == actual
    end
  end

  describe "solver tests" do
    @tag timeout: :infinity
    test "sample 1" do
      starting_rle = """
      x = 6, y = 6, rule = B3/S23
      2bo$bobo$o2b2o$b2o2bo$2bobo$3bo!
      """

      actual_rle =
        starting_rle
        |> RleParser.parse
        |> Game.run(4)
        |> RleParser.dump

      expected_rle = """
      x = 6, y = 6, rule = B3/S23
      bo2bo$o4bo3$o4bo$bo2bo!
      """ |> String.trim

        assert expected_rle == actual_rle
    end

    test "smiley face" do
      starting_rle = """
      x = 14, y = 11, rule = B3/S23
      4bo3bo$4bo3bo$4bo3bo$4bo3bo3$2o10b2o$bo10bo$b2o8b2o$2b3o5b2o$4b7o!
      """

      actual_rle =
        starting_rle
        |> RleParser.parse
        |> IO.inspect(label: "starting board")
        |> Game.run(1)
        |> IO.inspect(label: "ending board")
        |> RleParser.dump

      expected_rle = """
      x = 32, y = 29, rule = B3/S23
      17b3o$8b3o6b3o$8b3o6b3o$8b3o6b3o$8b2o8b2o$9b2o7b2o$10b2o6b3o$9b3o6b3o$
      9b3o6b3o$9b3o2$29b3o$b2o26b3o$b2o11b2o13b3o$2o12b2o13b3o$3o10b2o14b3o$
      2o11b3o13b3o$b2o10b2o2bo11b3o$14b4o11b3o$2b2o11b2o13b2o$29b2o$3bobo$3b
      o2bo21b2o$4bo2bo19b3o$5bo2bo17b3o$6bo17b4o$7b2obob15o$10b15o$11b11o!
      """ |> String.trim

      assert expected_rle == actual_rle
    end
  end

  test "fill in empty rows" do
    actual =
      [{6, [2, 5]}, {5, [1, 6]}, {2, [1, 6]}, {1, [2, 5]}]
      |> RleParser.fill_in_empty_rows
    expected = [{6, [2, 5]}, {5, [1, 6]}, {4, []}, {3, []}, {2, [1, 6]}, {1, [2, 5]}]

    assert expected == actual
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
