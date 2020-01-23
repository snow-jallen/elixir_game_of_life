defmodule ProcessDemo do
  def start do
    mem_pid = spawn(fn -> MemoryProcess.remember(0) end)
    spawn(fn -> ReporterProcess.report(mem_pid) end)
    mem_pid
  end

  def set_value(pid, num) do
    send(pid, {:set, num})
  end

  def get_value(mem_pid) do
    send(mem_pid, {:get, self()})
    receive do
      num -> num
    end
  end
end
