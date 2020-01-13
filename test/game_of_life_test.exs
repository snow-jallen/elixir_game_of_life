defmodule GameOfLifeTest do
  use ExUnit.Case

  describe "Board.advance/1" do
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

  describe "Game.run/2" do
    test "Test all steps" do
      starting_board = [%Cell{x: 3, y: -5},%Cell{x: 4, y: -8},%Cell{x: 5, y: -7},%Cell{x: 6, y: -8},%Cell{x: 6, y: -6},%Cell{x: 6, y: -5},%Cell{x: 7, y: -9},%Cell{x: 7, y: -8},%Cell{x: 7, y: -7},%Cell{x: 8, y: -8},%Cell{x: 8, y: -7},%Cell{x: 9, y: -6}]
      actual_board = Game.run(starting_board, 10)
      expected_board = [%Cell{x: 4, y: -9},%Cell{x: 2, y: -9},%Cell{x: 4, y: -8},%Cell{x: 5, y: -7},%Cell{x: 1, y: -8},%Cell{x: 1, y: -7},%Cell{x: 1, y: -6},%Cell{x: 2, y: -6},%Cell{x: 5, y: -6},%Cell{x: 5, y: -5},%Cell{x: 4, y: -4},%Cell{x: 3, y: -5},%Cell{x: 7, y: -6},%Cell{x: 7, y: -7},%Cell{x: 8, y: -5},%Cell{x: 7, y: -5},%Cell{x: 9, y: -7},%Cell{x: 9, y: -6},%Cell{x: 9, y: -8}]
      assert expected_board == actual_board, "Testing whole app"
    end
  end
end
