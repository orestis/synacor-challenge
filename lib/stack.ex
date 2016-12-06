defmodule Synacor.Stack do
  use GenServer
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, []}
  end

  def push(v) do
    GenServer.call(__MODULE__, {:push, v})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def handle_call({:push, v}, _from, stack) do
    {:reply, :ok, [v | stack]}
  end

  def handle_call(:pop, _from, [v | rest]) do
    {:reply, v, rest}
  end

end
