defmodule MemoryProcess do
  def remember(num) do
    receive do
      {:set, num} -> remember(num)
      {:get, pid} ->
        send(pid, num)
        remember(num)
    end
  end
end
