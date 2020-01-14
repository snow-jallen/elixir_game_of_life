defmodule SplitAndCombineTests do
  use ExUnit.Case

  describe "Board.create/2" do
    test "given a list of livecells appropriate min and max x/y are set" do
      livecells = [
        %Cell{x: 7, y: 7},
        %Cell{x: 7, y: -7},
        %Cell{x: -7, y: 7},
        %Cell{x: -7, y: -7}
      ]
      actual_board = Board.create(livecells)
      actual_board = %{actual_board | livecells: Enum.sort(actual_board.livecells)}
      expected_board = %Board{
        livecells: Enum.sort([
          %Cell{x:  7, y:  7},
          %Cell{x:  7, y: -7},
          %Cell{x: -7, y:  7},
          %Cell{x: -7, y: -7},
        ]),
        min_x: -7,
        max_x: 7,
        min_y: -7,
        max_y: 7
      }
      assert actual_board == expected_board
    end

    test "no cells gives an empty board" do
      livecells = []
      actual_board = Board.create(livecells)
      assert %Board{} == actual_board
    end
  end

  describe "Board.split/2" do
    test "standard board gets split into 4" do
      starting_board = Board.create([
          %Cell{x:  7, y: 7},
          %Cell{x: -7, y: 7}
        ])
      actual_boards = Enum.sort(Board.split(starting_board, 10))
      expected_boards = Enum.sort([
        %Board{
          livecells: [%Cell{x: -7, y: 7}],
          min_x: -7,
          max_x: 3,
          min_y: 7,
          max_y: 17
        },
        %Board{
          livecells: [%Cell{x: 7, y: 7}],
          min_x: 4,
          max_x: 14,
          min_y: 7,
          max_y: 17
        }
      ])
      assert expected_boards == actual_boards
    end
    # starting_board = Board.create(
    #     livecells: [
    #       %Cell{x:  7, y:  7},
    #       %Cell{x:  7, y: -7},
    #       %Cell{x: -7, y:  7},
    #       %Cell{x: -7, y: -7},
    #     ])
  end
end
