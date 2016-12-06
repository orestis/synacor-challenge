defmodule Synacor.Memory do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(_args) do
    {:ok, :array.new(32767+8)}
  end

  def write(address, c) when address < 32776 do
    GenServer.call(__MODULE__, {:write, address, c})
  end

  def read(address) when address < 32776 do
    GenServer.call(__MODULE__, {:read, address})
  end

  def handle_call({:read, address}, _from, mem) do
    c = :array.get(address, mem)
    IO.puts "address #{address} contains #{c}"
    c = if c > 32767, do: :array.get(c, mem), else: c
    {:reply, c, mem}
  end

  def handle_call({:write, address, c}, _from, mem) do
    mem = :array.set(address, c, mem)
    {:reply, :ok, mem}
  end
end
