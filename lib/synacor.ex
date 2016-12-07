defmodule Synacor do
  use Bitwise

  def start() do
    Synacor.Memory.start_link
    Synacor.Stack.start_link
    Synacor.Terminal.start_link
    b = File.read!("challenge.bin")
    {:ok, length} = load_program(b, 0)
    IO.puts "ELIXIR>>>> Loaded #{length} values"
    execute_program(0)
    IO.puts "ELIXIR>>>> finished execution"
  end

  def load_program(<<>>, addr), do: {:ok, addr}
  def load_program(<<lb::size(8), hb::size(8), rest::binary>>, addr) do
    v = (hb <<< 8) + lb
    Synacor.Memory.write(addr, v)
    load_program(rest, addr + 1)
  end

  def execute_program(:halt) do
    IO.puts "ELIXIR>>>> halting."
  end

  def execute_program(addr) do
    v = Synacor.Memory.read(addr)
    next_addr = eval(v, addr)
    execute_program(next_addr)
  end

  

  def eval(0, _), do: :halt
  def eval(1, addr) do # set
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    #IO.puts "opcode 1, write into reg #{a}, value #{b}"
    :ok = Synacor.Memory.write(a, b)
    addr + 3
  end
  def eval(2, addr) do # push
    a = Synacor.Memory.read(addr + 1)
    :ok = Synacor.Stack.push(a)
    addr + 2
  end
  def eval(3, addr) do # pop
    a = Synacor.Memory.read_noconv(addr + 1)
    v = Synacor.Stack.pop()
    :ok = Synacor.Memory.write(a, v)
    addr + 2
  end
  def eval(4, addr) do # eq
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    r = if b == c, do: 1, else: 0
    :ok = Synacor.Memory.write(a, r)
    addr + 4
  end
  def eval(5, addr) do # gt
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    r = if b > c, do: 1, else: 0
    :ok = Synacor.Memory.write(a, r)
    addr + 4
  end
  def eval(6, addr) do # jmp
    Synacor.Memory.read(addr + 1)
  end
  def eval(7, addr) do # jt
    a = Synacor.Memory.read(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    if a != 0, do: b, else: addr + 3
  end
  def eval(8, addr) do # jf
    a = Synacor.Memory.read(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    if a == 0, do: b, else: addr + 3
  end
  def eval(9, addr) do # add
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    :ok = Synacor.Memory.write(a, rem(b + c, 32768))
    addr + 4
  end
  def eval(10, addr) do # mult
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    :ok = Synacor.Memory.write(a, rem(b * c, 32768))
      addr + 4
  end
  def eval(11, addr) do # mod
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    :ok = Synacor.Memory.write(a, rem(b, c))
    addr + 4
  end
  def eval(12, addr) do # and
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    :ok = Synacor.Memory.write(a, b &&& c)
    addr + 4
  end
  def eval(13, addr) do # and
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    c = Synacor.Memory.read(addr + 3)
    :ok = Synacor.Memory.write(a, b ||| c)
    addr + 4
  end
  def eval(14, addr) do # not
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    :ok = Synacor.Memory.write(a, ~~~b &&& 32767)
    addr + 3
  end
  def eval(15, addr) do # rmem
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    m = Synacor.Memory.read(b)
    :ok = Synacor.Memory.write(a, m)
    addr + 3
  end
  def eval(16, addr) do # wmem
    a = Synacor.Memory.read(addr + 1)
    b = Synacor.Memory.read(addr + 2)
    :ok = Synacor.Memory.write(a, b)
    addr + 3
  end
  def eval(17, addr) do # call
    a = Synacor.Memory.read(addr + 1)
    :ok = Synacor.Stack.push(addr + 2)
    a
  end
  def eval(18, addr) do # ret
    a = Synacor.Stack.pop()
    a
  end
  def eval(19, addr) do
    v = Synacor.Memory.read(addr + 1)
    IO.write <<v>>
    addr + 2
  end
  def eval(20, addr) do
    a = Synacor.Memory.read_noconv(addr + 1)
    b = Synacor.Terminal.next_char()
    :ok = Synacor.Memory.write(a, b)
    addr + 2
  end
  def eval(21, addr), do: addr + 1

  def eval(opcode, addr) do
    IO.puts "ELIXIR>>>> unknown opcode #{inspect(opcode)} at addr #{addr} (#{addr * 2})"
    :halt
  end

end
