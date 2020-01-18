defmodule EncodeTest do
  use ExUnit.Case

  describe "encode/1" do
    test "encode([1,3])" do
      actual = RleParser.encode([1,3])
      expected = "obo$"
      assert actual == expected
    end
  end
end
