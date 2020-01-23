defmodule ReporterProcess do
  def report(mem_pid) do
    Process.sleep(7_000)
    send(mem_pid, {:get, self()})
    receive do
      num -> IO.puts "Memory is #{num}"
    end
    report(mem_pid)
  end
end
