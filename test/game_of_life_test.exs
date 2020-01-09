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
      expected_board = starting_board

      assert expected_board == actual_board
    end
  end

  describe "neighbor_count/2" do
    test "0 neighbors" do
      cell = %Cell{x: 1, y: 1}
      board = [cell]

      assert Board.neighbor_count(cell, board) == 0, "No neighbors"

    end
  end

end
