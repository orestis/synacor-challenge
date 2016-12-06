defmodule Synacor.Memory do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, :array.new(32768+8, [{:default,0}])}
  end

  def write(address, c) when address < 32776 do
    GenServer.call(__MODULE__, {:write, address, c})
  end

  def dump_registers() do
    GenServer.call(__MODULE__, :dump_registers)
  end

  def read(address) when address < 32776 do
    GenServer.call(__MODULE__, {:read, address})
  end

  def read_noconv(address) when address < 32776 do
    GenServer.call(__MODULE__, {:read_noconv, address})
  end

  def handle_call({:read, address}, _from, mem) do
    c = :array.get(address, mem)
    c = if c > 32767, do: :array.get(c, mem), else: c
    {:reply, c, mem}
  end

  def handle_call({:read_noconv, address}, _from, mem) do
    c = :array.get(address, mem)
    {:reply, c, mem}
  end

  def handle_call({:write, address, c}, _from, mem) do
    mem = :array.set(address, c, mem)
    {:reply, :ok, mem}
  end

  def handle_call(:dump_registers, _from, mem) do
    regs = for i <- 32768..32775, do: :array.get(i, mem)
    IO.puts "registers: #{inspect(regs)}" 
    {:reply, :ok, mem}
  end
end
