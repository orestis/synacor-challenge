defmodule Synacor.Terminal do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, ""}
  end

  def next_char() do
    GenServer.call(__MODULE__, :next_char, :infinity)
  end


  def handle_call(:next_char, _from, <<s>> <> rest) do
    {:reply, s, rest}
  end

  def handle_call(:next_char, _from, "") do
    <<s>> <> rest = IO.gets ""
    {:reply, s, rest}
  end
end
