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
      :observer.start
      starting_rle = """
x = 66, y = 94, rule = B3/S23
54bo$54b2o$56b2o$58bo$59bo$60bo$60bo$59bo$59bo$59bo$59bo$49bo8b2o$48b
2o10b2o$47bobo11bo$47b2o13bo$47b2o14bo$46b2o16bo$46bo17bo$46bo17bo$25b
o20b2o16bo$25bo19b3o15bo$25bo19b3o12b4o$25bo20b2o11b4o$25bo20b2o11b3ob
o$24bo3b2o16b2o15bo$24bo2b4o15b2o16bo$24bo2bob3o14bo17bo$24bo2b2o2b2o
13bo17bo$24bo2bo3b2o13bo17bo$b2o22b3ob2obo13b2o16bo$b2o22b5ob2o13bobo
15bo$obo21bo2b5o14bo2bo13bo$o2bo20bo16b6o3bo12bo$o2bo19bo27bo11bo$o2bo
19bo28bo10bo$o3bo18bo28bo9bo$o3bo18bo29bo7b2o$o3bo17bo31bo$o4bo16bo31b
o$o4bo16bo31bo$o4bo16bo14bo16bo$o4bo16bo12b3o16bo$o5bo15bo9b4o18bo$o5b
o15b10ob2o18bo$bo5bo24bo14bo4bo$bo5bo24bo12b3o3bo$bo29bo12b7o$bo29bo
12bob2o$2bo27bo12b2o$2bo27bob2o7b2o22bo$2bo26bob3o5b3o23bo$2bo26b3o5b
2o26bo$3bo24b4o3b2o28bo$3bo24b2o4bo30bo$4bo23bo3b2o31bo$5bo11b2o9b4o
33bo$5bo8b4o47bo$6b8o2bo48bo$15bo49bo$15bo48bo$14bo48bo$13bo49bo$12bo
49bo$12bo48bo$11bo49bo$10bo49bo$10bo47b2o$9bo47bo$9bo46bo$8bo45b2o$8bo
43b2o$7bo41b3o$7bo23b7o10bo$6bo21b3o7b4o5bo$6bo19b2o14bo4bo$6bo18bo16b
o4bo$5bo18bo18bo2b2o$5bo17bo19bobo$4bo17bo20b2o$4bo16bo19b3o$4bo15bo
18b2o2bo$4bo14bo17b2o4bo$3bo15bo15b2o5bo$3bo14bo14b2o7bo$3bo14bo10b4o
9bo$3bo13bo7b4o12bo$2bo15b7o14b2o$2bo35bo$2bo34bo$2bo31b3o$bo31bo$bo$b
o$bo!
"""

      actual_rle =
        starting_rle
        |> IO.inspect(label: "step 1 - parsing rle")
        |> RleParser.parse
        |> IO.inspect(label: "step 2 - running game")
        |> Game.run(1)
        |> IO.inspect(label: "step 3 - dumping rle")
        |> RleParser.dump

      expected_rle = """
      x = 68, y = 93, rule = B3/S23
      55b2o$55b3o$56b3o$58b2o$60bo$60b2o$60b2o$60b2o$59b3o$59b3o$60b2o$49b2o
      8b2o$50b2o8b3o$48bobo10b3o$47bo2bo12bo$64bo$47bobo14b2o$46b2o16b3o$46b
      2o16b3o$64b2o$25b3o21bo12bob2o$25b3o21bo10bo3bo$25b3o21bo$25b2o19bo2bo
      10bo3bo$25b2obo2bo14bo2bo11bob3o$24b3obo3bo13bo17b2o$24b4o5bo12b2o16b
      3o$24b5obo15b3o15b3o$25bo4bo3bo11b2o16b3o$2b2o21bo4bo3bo11b2o16b3o$bo
      2bo20bo7bo12b2obo14b2o$bob2o20bo6b2o9b3obo2bo13b2o$2ob2o19b2o3b3o11b5o
      3bo11b3o$6o18b2o17b4o5bo10b3o$3ob2o17b3o26b2o9b2o$3ob2o17b3o27b2o7b3o$
      3ob3o16b2o29bo7b2o$3o2b2o16b2o29b2o$3o2b2o15b3o29b3o$3o2b3o14b3o29b3o$
      3o2b3o14b3o13bo15b3o$3o3b2o14b3o9bobobo15b3o$3o3b2o14b2ob9o20b2o$b2o4b
      2o14b10o3bo17bo$b2o4b2o15b8obo14bo4bo$b3o28b2o11bo4b3o$b3o28b2o11bo4b
      2o$2b2o27b2o17bo$2b2o27bobo9b4o$2b3o25b2o2bo7b3o$2b3o25bo3bo4b5o21b3o$
      3b2o32b5o23b3o$3b2o27bo3b3o26b3o$4b2o22bo3b5o28b3o$5bo22bo3b3o30b3o$5b
      2o9bob2o9b5o31b3o$6bob9o2bo10b2o33b3o$7b8o3bo46b3o$8b6ob3o47b2o$15b2o
      48bo$15bo48b2o$14bo48b2o$13b2o48bo$12b2o48b2o$12bo48b2o$11b2o47b2o$10b
      2o47b2o$10b2o46b2o$9b2o45b2o$9b2o43b3o$8b2o41b5o$8b2o23b5o12b4o$7b2o
      21b12o7b3o$7b2o19b15o5b2o$6b3o18b4o9b2obo3b3o$6b2o18b2o15b2o3b2o$6b2o
      17bo17b3ob2o$5b2o17bo18b2ob2o$5b2o16bo$4b3o15bo18b2o$4b3o14bo17b4ob2o$
      4b2o14b2o15b4o2b2o$4b2o13b2o14b4o4b2o$3b3o13b2o10b6o5b3o$3b3o12b2o7b8o
      7b2o$3b2o13bo2b12o8b2o$3b2o14b10o11b2o$2b3o15b5o14b2o$2b3o31b3o$2b2o
      31b3o$2b2o31b2o$b3o$b3o!
      """

        assert expected_rle == actual_rle
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
